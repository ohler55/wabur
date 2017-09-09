
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

      # Returns the instance converted to native Ruby values such as a Hash,
      # Array, etc.
      alias native root

      # Returns true if the Data element or value identified by the path
      # exists where the path elements are separated by the '.' character. The
      # path can also be a array of path node identifiers. For example,
      # child.grandchild is the same as ['child', 'grandchild'].
      def has?(path)
        if path.is_a?(Symbol)
          return @root.is_a?(Hash) && @root.has_key?(path)
        else
          path = path.to_s.split('.') unless path.is_a?(Array)
          node = @root
          path.each { |key|
            if node.is_a?(Hash)
              key = key.to_sym
              return false unless node.has_key?(key)
              node = node[key]
            elsif node.is_a?(Array)
              i = key.to_i
              return false if 0 == i && '0' != key && 0 != key
              len = node.length
              return false unless -len <= i && i < len
              node = node[i]
            else
              return false
            end
          }
        end
        true
      end

      # Gets the Data element or value identified by the path where the path
      # elements are separated by the '.' character. The path can also be a
      # array of path node identifiers. For example, child.grandchild is the
      # same as ['child', 'grandchild'].
      def get(path)
        if path.is_a?(Symbol)
          node = @root[path] 
        else
          path = path.to_s.split('.') unless path.is_a?(Array)
          node = @root
          path.each { |key|
            if node.is_a?(Hash)
              node = node[key.to_sym]
            elsif node.is_a?(Array)
              i = key.to_i
              if 0 == i && '0' != key && 0 != key
                node = nil
                break
              end
              node = node[i]
            else
              node = nil
              break
            end
          }
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
        raise WAB::Error, "path can not be empty." if path.empty?
        if value.is_a?(::WAB::Data)
          value = value.native
        elsif repair
          value = fix_value(value)
        else
          validate_value(value)
        end
        node = @root
        path = path.to_s.split('.') unless path.is_a?(Array)
        path[0..-2].each { |key|
          if node.is_a?(Hash)
            key = key.to_sym
            node[key] = {} unless node.has_key?(key)
            node = node[key]
          elsif node.is_a?(Array)
            key = key_to_int(key)
            if key < node.length && -node.length < key
              node = node[key]
            else
              nn = {}
              if key < -node.length
                node.unshift(nn)
              else
                node[key] = nn
              end
              node = nn
            end
          else
            raise WAB::TypeError, "Can not set a member of an #{node.class}."
          end
        }
        key = path[-1]
        if node.is_a?(Hash)
          key = key.to_sym
          node[key] = value
        elsif node.is_a?(Array)
          key = key_to_int(key)
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

      # Each child of the Data instance is provided as an argument to a block
      # when the each method is called.
      def each(&block)
        each_node([], @root, block)
      end

      # Each leaf of the Data instance is provided as an argument to a block
      # when the each method is called. A leaf is a primitive that has no
      # children and will be nil, a Boolean, String, Numberic, Time, WAB::UUID,
      # or URI.
      def each_leaf(&block)
        each_leaf_node([], @root, block)
      end

      # Make a deep copy of the Data instance.
      def deep_dup()
        # avoid validation by using a empty Hash for the intial value.
        c = self.class.new({}, false)
        c.instance_variable_set(:@root, deep_dup_value(@root))
        c
      end

      # Returns true if self and other are either the same or have the same
      # contents. This is a deep comparison.
      def eql?(other)
        # Any object that is of a class derived from the API class is a
        # candidate for being ==.
        return false unless other.is_a?(::WAB::Data)
        values_eql?(@root, other.native)
      end
      alias == eql?
      
      # Returns the length of the root element.
      def length()
        @root.length
      end

      # Returns the number of leaves in the data tree.
      def leaf_count()
        branch_count(@root)
      end

      # Returns the number of nodes in the data tree.
      def size()
        branch_size(@root)
      end

      # Encode the data as a JSON string.
      def json(indent=0)
        Oj.dump(@root, mode: :wab, indent: indent)
      end

      # Detects and converts strings to Ruby objects following the rules:
      # Time:: "2017-01-05T15:04:33.123456789Z", zulu only
      # UUID:: "b0ca922d-372e-41f4-8fea-47d880188ba3"
      # URI:: "http://opo.technology/sample", HTTP only
      def detect()
        return detect_hash(@root) if @root.is_a?(Hash)
        detect_array(@root) if @root.is_a?(Array)
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
            raise WAB::KeyError unless k.is_a?(Symbol)
            validate_value(v)
          }
        elsif value.is_a?(Array)
          value.each { |v|
            validate_value(v)
          }
        else
          raise WAB::TypeError
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
            raise WAB::KeyError unless k.is_a?(Symbol)
            validate_value(v)
          }
        elsif Array == value_class
          value.each { |v|
            validate_value(v)
          }
        elsif WAB::Utils.pre_24_fixnum?(value)
          # valid value
        else
          raise WAB::TypeError, "#{value_class} is not a valid Data value."
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
          raise WAB::TypeError unless value.is_a?(Hash)
          value = fix(value)
        else
          raise WAB::TypeError
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
        elsif WAB::Utils.pre_24_fixnum?(value)
          # valid value
        elsif value.respond_to?(:to_h) && 0 == value.method(:to_h).arity
          value = value.to_h
          raise WAB::TypeError unless value.is_a?(Hash)
          value = fix(value)
        elsif value.respond_to?(:to_s)
          value = value.to_s
          raise StandardError.new("Data values must be either a Hash or an Array") unless value.is_a?(String)
        else
          raise WAB::TypeError, "#{value_class} is not a valid Data value."
        end
        value
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
        return key if WAB::Utils.pre_24_fixnum?(key)

        raise WAB::Error, "path key must be an integer for an Array."
      end

      def deep_dup_value(value)
        if value.is_a?(Hash)
          c = {}
          value.each_pair { |k, v| c[k] = deep_dup_value(v) }
        elsif value.is_a?(Array)
          c = []
          value.each { |v| c << deep_dup_value(v) }
        else
          value_class = value.class
          if value.nil? ||
            TrueClass == value_class ||
            FalseClass == value_class ||
            Integer == value_class ||
            Float == value_class ||
            String == value_class
            c = value
          elsif WAB::Utils.pre_24_fixnum?(value)
            c = value
          else
            c = value.dup
          end
        end
        c
      end

      def detect_hash(h)
        h.each_key { |k| detect_elememt(h, k) }
      end

      def detect_array(a)
        a.each_index { |i| detect_elememt(a, i) }
      end

      def detect_elememt(collection, key)
        item = collection[key]

        case item
        when Hash
          detect_hash(item)
        when Array
          detect_array(item)
        when String
          element = ::WAB::Impl::Data.detect_string(item)
          collection[key] = element unless element == item
        end
      end

      def self.detect_string(s)
        len = s.length
        if 36 == len && WAB::Utils.uuid_format?(s)
          ::WAB::UUID.new(s)
        elsif 30 == len && WAB::Utils.wab_time_format?(s)
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
