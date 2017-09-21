
module WAB
  module Impl
    module Utils

      class << self

        # Convert a given key to an +Integer+ or raise based on the
        # conversion-mode.
        #
        # Returns zero integer on unsuccessful conversion.
        # Raises on unsuccessful conversion under 'strict' mode.
        def convert_to_integer(key, mode = nil)
          return key if key.is_a?(Integer)

          key = key.to_s if key.is_a?(Symbol)
          if key.is_a?(String)
            i = key.to_i
            return i if i.to_s == key
          end
          return key if WAB::Utils.pre_24_fixnum?(key)

          return 0 unless mode == "strict"
          raise WAB::Error, 'path key must be an integer for an Array.'
        end


        # Gets the Data element or value identified by the path where the path
        # elements are separated by the '.' character.
        def get_node(root, path)
          return root[path] if path.is_a?(Symbol)

          path = path.to_s.split('.') unless path.is_a?(Array)
          node = root

          path.each { |key|
            if node.is_a?(Hash)
              node = node[key.to_sym]
            elsif node.is_a?(Array)
              i = key.to_i
              return nil if i.zero? && key != i && key != i.to_s
              node = node[i]
            else
              return nil
            end
          }

          node
        end

        # Sets the node value identified by the path where the path elements are
        # separated by the '.' character.
        def set_value(node, path, value)
          path = path.to_s.split('.') unless path.is_a?(Array)

          path[0..-2].each_index { |i|
            key = path[i]
            if node.is_a?(Hash)
              key = key.to_sym
              unless node.has_key?(key)
                node[key] = convert_to_integer(path[i + 1]).zero? ? {} : []
              end
              node = node[key]
            elsif node.is_a?(Array)
              key = convert_to_integer(key, "strict")
              if key < node.length && -node.length < key
                node = node[key]
              else
                entry = convert_to_integer(path[i + 1]).zero? ? {} : []
                if key < -node.length
                  node.unshift(entry)
                else
                  node[key] = entry
                end
                node = entry
              end
            else
              raise WAB::TypeError, "Can not set a member of an #{node.class}."
            end
          }

          key = path[-1]

          if node.is_a?(Hash)
            node[key.to_sym] = value
          elsif node.is_a?(Array)
            key = convert_to_integer(key, "strict")
            if key < -node.length
              node.unshift(value)
            else
              node[key] = value
            end
          else
            raise WAB::TypeError, "Can not set a member of an #{node.class}."
          end
          value
        end

      end # Singleton class

    end # Utils
  end # Impl
end # WAB
