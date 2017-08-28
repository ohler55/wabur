
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
        @map[ref]
      end

      def query(tql)
        puts "*** TQL: #{tql}"
        if tql.has_key?(:insert)
          insert(tql)
        elsif tql.has_key?(:update)
          update(tql)
        elsif tql.has_key?(:delete)
          delete(tql)
        else
          select(tql)
        end
      end

      def gen_ref
        @lock.synchronize {
          @cnt += 1
        }
      end

      def insert(tql)
        ref = gen_ref
        obj = tql[:insert]
        @map[ref] = obj
        write_to_file(ref, obj)
        { code: 0, ref: ref }
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
      
      def update(tql)
        # TBD
      end
      
      def delete(tql)
        where = tql[:where]
        deleted = []
        if where.is_a?(Array)
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
