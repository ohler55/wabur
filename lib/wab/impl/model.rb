
require 'wab'
require 'wab/impl/expr'

module WAB
  module Impl

    # 
    class Model

      def initialize(dir)
        @dir = dir
        @cnt = 0
        @map = {}
        @lock = Thread::Mutex.new()
        # TBD load from files in dir
      end

      def get(ref)
        { code: 0, results: [ { id: ref, data: @map[ref].native } ] }
      end

      def query(tql)
        rid = tql[:rid]
        where = nil
        filter = nil
        if tql.has_key?(:where)
          w = tql[:where]
          if w.is_a?(Array)
            where = Expr.parse(w)
          else
            where = w
          end
        end
        filter = Expr.parse(tql[:filter]) if tql.has_key?(:filter)
        
        #puts "*** TQL: #{tql}"
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

      def gen_ref
        @lock.synchronize {
          @cnt += 1
        }
      end

      def insert(obj, rid, where, filter)
        # TBD check where and filter for conflicts
        ref = gen_ref
        @map[ref] = Data.new(obj, true)
        write_to_file(ref, obj)
        result = { code: 0, ref: ref }
        result[:rid] = rid unless rid.nil?
        result
      end

      def select(tql)
        # TBD just a mock 
        { code: 0,
          results: [
                    {
                      ref: 1,
                      name: 'Sample',
                      body: "Mock me"
                    }
                   ]
        }
      end
      
      def update(obj, rid, where, filter)
        # TBD
      end
      
      def delete(del_opt, rid, where, filter)
        deleted = []
        if where.is_a?(Expr)
          # TBD and expression
        else
          # A reference.
          unless @map.delete(where).nil?
            deleted << where
            remove_file(where)
          end
        end
        { code: 0, deleted: delected }
      end
      
      def write_to_file(ref, obj)
        # TBD
      end

      def remove_file(ref)
        # TBD
      end

    end # Model
  end # Impl
end # WAB
