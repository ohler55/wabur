
require 'date'
require 'uri'
require 'oj'

module WAB
  module Impl

    # The class representing the cananical data structure in WAB. Typically
    # the Data instances are factory created by the Shell and will most likely
    # not be instance of this class but rather a class that is a duck-type of
    # this class (has the same methods and behavior).
    class Data < ::WAB::Data
      attr_reader :root

      # This method should not be called directly. New instances should be
      # created by using a Shell#data method.
      #
      # Creates a new Data instance with the initial value provided. The value
      # must be a Hash or Array. The members of the Hash or Array must be nil,
      # boolean, String, Integer, Float, BigDecimal, Array, Hash, Time,
      # WAB::UUID, or the Ruby URI::HTTP.
      #
      # value:: initial value
      # repair:: flag indicating invalid value should be repaired if possible
      def initialize(value, repair, check=true)
        if repair
          value = fix(value)
        elsif check
          validate(value)
        end
        @root = value
      end

      # Gets the Data element or value identified by the path where the path
      # elements are separated by the '.' character. The path can also be a
      # array of path node identifiers. For example, child.grandchild is the
      # same as ['child', 'grandchild'].
      def get(path)
        if path.is_a?(Symbol)
          node = root[path]
        else
          path = path.to_s.split('.') unless path.is_a?(Array)
          node = extract_node(path, root)
        end

        return Data.new(node, false, false) if node.is_a?(Hash) || node.is_a?(Array)

        node
      end

      # Sets the node value identified by the path where the path elements are
      # separated by the '.' character. The path can also be a array of path
      # node identifiers. For example, child.grandchild is the same as ['child',
      # 'grandchild']. The value must be one of the allowed data values
      # described in the initialize method.
      #
      # For arrays, the behavior is similar to an Array#[] with the exception
      # of a negative index less than the negative length in which case the
      # value is prepended (Array#unshift).
      #
      # path:: path to location to be set
      # value:: value to set
      # repair:: flag indicating invalid value should be repaired if possible
      def set(path, value, repair=false)
        raise StandardError.new("path can not be empty.") if path.empty?
        if value.is_a?(::WAB::Data)
          value = value.native
        elsif repair
          value = fix_value(value)
        else
          validate_value(value)
        end
        path = path.to_s.split('.') unless path.is_a?(Array)
        node = assign_node(path, root)

        key = path[-1]
        ensure_hash_or_array(node)
        if node.is_a?(Hash)
          key = key.to_sym
          node[key] = value
        else # node is an instance of Array
          key = key_to_int(key)
          if key < -node.length
            node.unshift(value)
          else
            node[key] = value
          end
        end
        value
      end

      # Each child of the Data instance is provided as an argument to a block
      # when the each method is called.
      def each(&block)
        each_node([], root, block)
      end

      # Each leaf of the Data instance is provided as an argument to a block
      # when the each method is called. A leaf is a primitive that has no
      # children and will be nil, a Boolean, String, Numberic, Time, WAB::UUID,
      # or URI.
      def each_leaf(&block)
        each_leaf_node([], root, block)
      end

      # Make a deep copy of the Data instance.
      def clone()
        # avoid validation by using a empty Hash for the intial value.
        c = self.class.new({}, false)
        c.instance_variable_set(:@root, clone_value(root))
        c
      end

      # Returns the instance converted to native Ruby values such as a Hash,
      # Array, etc.
      def native()
        root
      end

      # Returns true if self and other are either the same or have the same
      # contents. This is a deep comparison.
      def eql?(other)
        # Any object that is of a class derived from the API class is a
        # candidate for being ==.
        return false unless other.is_a?(::WAB::Data)
        values_eql?(root, other.native)
      end
      alias == eql?
      
      # Returns the length of the root element.
      def length()
        root.length
      end

      # Returns the number of leaves in the data tree.
      def leaf_count()
        branch_count(root)
      end

      # Returns the number of nodes in the data tree.
      def size()
        branch_size(root)
      end

      # Encode the data as a JSON string.
      def json(indent=0)
        Oj.dump(root, mode: :wab, indent: indent)
      end

      # Detects and converts strings to Ruby objects following the rules:
      # Time:: "2017-01-05T15:04:33.123456789Z", zulu only
      # UUID:: "b0ca922d-372e-41f4-8fea-47d880188ba3"
      # URI:: "http://opo.technology/sample", HTTP only
      def detect()
        if root.is_a?(Hash)
          detect_hash(root)
        elsif root.is_a?(Array)
          detect_hash(root)
        end
      end

      private

      # Raise an exception if the value is not a suitable data element. If the
      # repair flag is true an attempt is made to fix the value if possible by
      # replacing non-symbol keys with Symbols and converting unsupported
      # objects with a to_h or a to_s.
      #
      # value:: value to validate
      def validate(value)
        if value.is_a?(Hash)
          value.each_pair { |k, v| 
            raise StandardError.new("Hash keys must be Symbols.") unless k.is_a?(Symbol)
            validate_value(v)
          }
        elsif value.is_a?(Array)
          value.each { |v|
            validate_value(v)
          }
        else
          raise StandardError.new("Data values must be either a Hash or an Array")
        end
        value
      end

      def validate_value(value)
        value_class = value.class
        if value.nil? ||
            TrueClass == value_class ||
            FalseClass == value_class ||
            Integer == value_class ||
            Float == value_class ||
            String == value_class ||
            Time == value_class ||
            BigDecimal == value_class ||
            URI::HTTP == value_class ||
            ::WAB::UUID == value_class
          # valid values
        elsif Hash == value_class
          value.each_pair { |k, v| 
            raise StandardError.new("Hash keys must be Symbols.") unless k.is_a?(Symbol)
            validate_value(v)
          }
        elsif Array == value_class
          value.each { |v|
            validate_value(v)
          }
        elsif '2' == RbConfig::CONFIG['MAJOR'] && '4' > RbConfig::CONFIG['MINOR'] && Fixnum == value_class
          # valid value
        else
          raise StandardError.new("#{value_class.to_s} is not a valid Data value.")
        end
        value
      end

      # Fix values by returing either the value or the fixed alternative. In
      # the cases of Hash and Array a copy is always made. (its just easier)
      def fix(value)
        if value.is_a?(Hash)
          old = value
          value = {}
          old.each_pair { |k, v|
            k = k.to_sym unless k.is_a?(Symbol)
            value[k] = fix_value(v)
          }
        elsif value.is_a?(Array)
          old = value
          value = []
          old.each { |v|
            value << fix_value(v)
          }
        elsif value.respond_to?(:to_h) && 0 == value.method(:to_h).arity
          value = value.to_h
          raise StandardError.new("Data values must be either a Hash or an Array") unless value.is_a?(Hash)
          value = fix(value)
        else
          raise StandardError.new("Data values must be either a Hash or an Array")
        end
        value
      end

      def fix_value(value)
        value_class = value.class
        if value.nil? ||
            TrueClass == value_class ||
            FalseClass == value_class ||
            Integer == value_class ||
            Float == value_class ||
            String == value_class ||
            Time == value_class ||
            BigDecimal == value_class ||
            URI::HTTP == value_class ||
            ::WAB::UUID == value_class
          # valid values
        elsif Hash == value_class
          old = value
          value = {}
          old.each_pair { |k, v|
            k = k.to_sym unless k.is_a?(Symbol)
            value[k] = fix_value(v)
          }
        elsif Array == value_class
          old = value
          value = []
          old.each { |v|
            value << fix_value(v)
          }
        elsif '2' == RbConfig::CONFIG['MAJOR'] && '4' > RbConfig::CONFIG['MINOR'] && Fixnum == value_class
          # valid value
        elsif value.respond_to?(:to_h) && 0 == value.method(:to_h).arity
          value = value.to_h
          raise StandardError.new("Data values must be either a Hash or an Array") unless value.is_a?(Hash)
          value = fix(value)
        elsif value.respond_to?(:to_s)
          value = value.to_s
          raise StandardError.new("Data values must be either a Hash or an Array") unless value.is_a?(String)
        else
          raise StandardError.new("#{value_class.to_s} is not a valid Data value.")
        end
        value
      end

      def extract_node(path, root)
        path.each do |key|
          if root.is_a?(Hash)
            root = root[key.to_sym]
          elsif root.is_a?(Array)
            i = key.to_i
            if 0 == i && '0' != key && 0 != key
              root = nil
            end
            root = root[i]
          else
            root = nil
          end
        end
        root
      end

      def assign_node(path, root)
        path[0..-2].each do |key|
          ensure_hash_or_array(root)
          if root.is_a?(Hash)
            key = key.to_sym
            root[key] = {} unless root.has_key?(key)
            root = root[key]
          else # root is an instance of Array
            key = key_to_int(key)
            if key < root.length && -root.length < key
              root = root[key]
            else
              nn = {}
              if key < -root.length
                root.unshift(nn)
              else
                root[key] = nn
              end
              root = nn
            end
          end
        end
        root
      end

      def ensure_hash_or_array(node)
        unless node.is_a?(Hash) || node.is_a?(Array)
          raise StandardError.new("Can not set a member of an #{node.class}.")
        end
      end

      def each_node(path, value, block)
        block.call(path, value)
        if value.is_a?(Hash)
          value.each_pair { |k, v| each_node(path + [k], v, block) }
        elsif value.is_a?(Array)
          value.each_index { |i| each_node(path + [i], value[i], block) }
        end
      end

      def each_leaf_node(path, value, block)
        if value.is_a?(Hash)
          value.each_pair { |k, v| each_leaf_node(path + [k], v, block) }
        elsif value.is_a?(Array)
          value.each_index { |i| each_leaf_node(path + [i], value[i], block) }
        else
          block.call(path, value)
        end
      end

      def branch_count(value)
        cnt = 0
        if value.is_a?(Hash)
          value.each_value { |v| cnt += branch_count(v) }
        elsif value.is_a?(Array)
          value.each { |v| cnt += branch_count(v) }
        else
          cnt = 1
        end
        cnt
      end

      def branch_size(value)
        cnt = 1
        if value.is_a?(Hash)
          value.each_value { |v| cnt += branch_size(v) }
        elsif value.is_a?(Array)
          value.each { |v| cnt += branch_size(v) }
        end
        cnt
      end

      def values_eql?(v0, v1)
        return false unless v0.class == v1.class
        if v0.is_a?(Hash)
          return false unless v0.length == v1.length
          v0.each_key { |k|
            return false unless values_eql?(v0[k], v1[k])
            return false unless v1.has_key?(k)
          }
        elsif v0.is_a?(Array)
          return false unless v0.length == v1.length
          v0.each_index { |i|
            return false unless values_eql?(v0[i], v1[i])
          }
        else
          v0 == v1
        end
      end

      def key_to_int(key)
        return key if key.is_a?(Integer)

        key = key.to_s if key.is_a?(Symbol)
        if key.is_a?(String)
          i = key.to_i
          return i if i.to_s == key
        end
        return key if '2' == RbConfig::CONFIG['MAJOR'] && '4' > RbConfig::CONFIG['MINOR'] && key.is_a?(Fixnum)

        raise StandardError.new("path key must be an integer for an Array.") unless i.to_s == key
      end

      def clone_value(value)
        if value.is_a?(Hash)
          c = {}
          value.each_pair { |k, v| c[k] = clone_value(v) }
        elsif value.is_a?(Array)
          c = []
          value.each { |v| c << clone_value(v) }
        else
          value_class = value.class
          if value.nil? ||
            TrueClass == value_class ||
            FalseClass == value_class ||
            Integer == value_class ||
            Float == value_class ||
            String == value_class
            c = value
          elsif '2' == RbConfig::CONFIG['MAJOR'] && '4' > RbConfig::CONFIG['MINOR'] && Fixnum == value_class
            c = value
          else
            c = value.clone
          end
        end
        c
      end

      def detect_hash(h)
        h.each_key { |k|
          v = h[k]
          vc = v.class
          if Hash == vc
            detect_hash(v)
          elsif Array == vc
            detect_array(v)
          elsif String == vc
            v2 = detect_string(v)
            h[k] = v2 if v2 != v
          end
        }
      end

      def detect_array(a)
        a.each_index { |i|
          v = a[i]
          vc = v.class
          if Hash == vc
            detect_hash(v)
          elsif Array == vc
            detect_array(v)
          elsif String == vc
            v2 = detect_string(v)
            a[i] = v2 if v2 != v
          end
        }
      end

      def detect_string(s)
        len = s.length
        if 36 == len && !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match(s).nil?
          ::WAB::UUID.new(s)
        elsif 30 == len && !/^\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d{9}Z$/.match(s).nil?
          begin
            DateTime.parse(s).to_time()
          rescue
            s
          end
        elsif s.downcase().start_with?('http://')
          begin
            URI(s)
          rescue
            s
          end
        else
          s
        end
      end

    end # Data
  end # Impl
end # WAB
