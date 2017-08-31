
require 'oj'
require 'wab'
require 'wab/impl/expr'
require 'wab/impl/exprparse'

module WAB
  module Impl

    # The Model class is used to store data when using the
    # ::WAB::Impl::Shell. It is no intended for any other use. The *get* and
    # *query* methods are the primary means of interacting with the model.
    #
    # The Model is simple in that it stores data in a Hash references by *ref*
    # numbers. Data is stores in a directory as separate JSON files that are
    # named as the *ref* number as a 16 character hexidecimal.
    class Model

      # Create a new Model using the designated directory as the store.
      #
      # dir:: directory to store data in
      def initialize(dir)
        @dir = dir.nil? ? nil : ::File.expand_path(dir)
        @cnt = 0
        @map = {}
        @lock = Thread::Mutex.new()
        Dir.mkdir(@dir) unless @dir.nil? || Dir.exist?(@dir)
        load_files()
      end

      # Get a single record in the database. A ::WAB::Impl::Data object is
      # returned if not nil.
      #
      # ref:: references number of the object to retrieve.
      def get(ref)
        @map[ref]
      end

      # Execute a TQL query.
      #
      # _Note that the current implementation does not support nested data
      # retrieval.
      #
      # tql:: query to execute
      def query(tql)
        rid = tql[:rid]
        where = nil
        filter = nil
        if tql.has_key?(:where)
          w = tql[:where]
          where = (w.is_a?(Array) ? Expr.parse(w) : w)
        end
        filter = Expr.parse(tql[:filter]) if tql.has_key?(:filter)
        
        if tql.has_key?(:insert)
          insert(tql[:insert], rid, where, filter)
        elsif tql.has_key?(:update)
          update(tql[:update], rid, where, filter)
        elsif tql.has_key?(:delete)
          delete(tql[:delete], rid, where, filter)
        else
          select(tql[:select], rid, where, filter)
        end
      end

      private
      
      def insert(obj, rid, where, filter)
        ref = nil
        @lock.synchronize {
          unless where.nil?
            @map.each_value { |v|
              if where.eval(v) && (filter.nil? || filter.eval(v))
                result = { code: -1, error: 'Already exists.' }
                result[:rid] = rid unless rid.nil?
                return result
              end
            }
          end
          @cnt += 1
          ref = @cnt
          @map[ref] = Data.new(obj, true)
          write_to_file(ref, obj)
        }
        result = { code: 0, ref: ref }
        result[:rid] = rid unless rid.nil?
        result
      end

      def select(format, rid, where, filter)
        matches = []
        @lock.synchronize {
          if where.nil? && filter.nil?
            @map.each { |ref,obj|
              if format.nil?
                matches << { id: ref, data: obj.native }
              else
                matches << format_obj(format, ref, rid, obj)
              end
            }
          else
            @map.each { |ref,obj|
              if where.eval(obj) && (filter.nil? || filter.eval(obj))
                if format.nil?
                  matches << { id: ref, data: obj.native }
                else
                  matches << format_obj(format, ref, rid, obj)
                end
              end
            }
          end
        }
        result = { code: 0, results: matches }
        result[:rid] = rid unless rid.nil?
        result
      end
      
      def update(obj, rid, where, filter)
        updated = []
        @lock.synchronize {
          if where.is_a?(Expr)
            # TBD must be able to update portions of an object
          else
            # A reference.
            @map[where] = Data.new(obj, true)
            updated << where
            write_to_file(where, obj)
          end
        }
        { code: 0, updated: updated }
      end
      
      def delete(del_opt, rid, where, filter)
        deleted = []
        @lock.synchronize {
          if where.is_a?(Expr)
            @map.each { |ref,obj|
              if where.eval(obj) && (filter.nil? || filter.eval(obj))
                deleted << ref
                @map.delete(ref)
              end
            }
          else
            # A reference.
            unless @map.delete(where).nil?
              deleted << where
              remove_file(where)
            end
          end
        }
        { code: 0, deleted: deleted }
      end

      def format_obj(format, ref, rid, obj)
        case format
        when Hash
          native = {}
          format.each { |k,v| native[k] = format_obj(v, ref, rid, obj) }
          native
        when Array
          format.map { |v| format_obj(v, ref, rid, obj) }
        when String
          if '$ref' == format
            ref
          elsif '$rid' == format
            rid
          elsif '$' == format || '$root' == format
            obj.native
          elsif 0 < format.length && '\'' == format[0]
            format[1..-1]
          else
            obj.get(format)
          end
        else
          format
        end
      end

      def load_files()
        unless @dir.nil?
          Dir.foreach(@dir) { |fn|
            next if '.' == fn[0]
            ref = fn[0..-6]
            @map[ref.to_i(16)] = Data.new(Oj.load_file(File.join(@dir, fn), mode: :wab), true)
          }
        end
      end
      
      def write_to_file(ref, obj)
        unless @dir.nil?
          obj.native if obj.is_a?(::WAB::Data)
          File.open(File.join(@dir, "%016x.json" % ref), "wb") { |f| f.write(Oj.dump(obj, mode: :wab, indent: 0)) }
        end
      end

      def remove_file(ref)
        File.delete(File.join(@dir, "%016x.json" % ref)) unless @dir.nil?
      end

    end # Model
  end # Impl
end # WAB
