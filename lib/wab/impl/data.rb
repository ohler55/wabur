
require 'date'
require 'uri'
require 'oj'

module WAB
  module Impl

    # The class representing the canonical data structure in WAB. Typically
    # the Data instances are factory created by the Shell and will most likely
    # not be instance of this class but rather a class that is a duck-type of
    # this class (has the same methods and behavior).
    class Data < WAB::Data
      attr_reader :root

      def self.detect_string(s)
        if WAB::Utils.uuid_format?(s)
          WAB::UUID.new(s)
        elsif WAB::Utils.wab_time_format?(s)
          begin
            DateTime.parse(s).to_time
          rescue
            s
          end
        elsif s.downcase.start_with?('http://')
          begin
            URI(s)
          rescue
            s
          end
        else
          s
        end
      end

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
      def initialize(value, repair=false, check=true)
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
        return (@root.is_a?(Hash) && @root.has_key?(path)) if path.is_a?(Symbol)

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
        true
      end

      # Gets the Data element or value identified by the path where the path
      # elements are separated by the '.' character. The path can also be a
      # array of path node identifiers. For example, child.grandchild is the
      # same as ['child', 'grandchild'].
      def get(path)
        node = Utils.get_node(@root, path)

        return node unless node.is_a?(Hash) || node.is_a?(Array)
        Data.new(node, false, false)
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
        raise WAB::Error, 'path can not be empty.' if path.empty?
        if value.is_a?(WAB::Data)
          value = value.native
        elsif repair
          value = fix_value(value)
        else
          validate_value(value)
        end
        node = @root
        Utils.set_value(node, path, value)
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
        c = Data.new({})
        c.instance_variable_set(:@root, deep_dup_value(@root))
        c
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
          validate_hash(value)
        elsif value.is_a?(Array)
          value.each { |v| validate_value(v) }
        else
          raise WAB::TypeError
        end
        value
      end

      def validate_value(value)
        return value if valid_class(value)
        if value.is_a?(Hash)
          validate_hash(value)
        elsif value.is_a?(Array)
          value.each { |v| validate_value(v) }
        else
          raise WAB::TypeError, "#{value_class} is not a valid Data value."
        end
      end

      def validate_hash(hsh)
        hsh.each_pair { |k, v|
          raise WAB::KeyError unless k.is_a?(Symbol)
          validate_value(v)
        }
      end

      def valid_class(value)
        value_class = value.class
        value.nil? ||
          TrueClass  == value_class ||
          FalseClass == value_class ||
          Integer    == value_class ||
          Float      == value_class ||
          String     == value_class ||
          Time       == value_class ||
          BigDecimal == value_class ||
          URI::HTTP  == value_class ||
          WAB::UUID  == value_class ||
          WAB::Utils.pre_24_fixnum?(value)
      end

      # Fix values by returing either the value or the fixed alternative.
      def fix(value)
        value_class = value.class
        if Hash == value_class
          value = fix_hash(value)
        elsif Array == value_class
          value = value.map { |v| fix_value(v) }
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
        return value if valid_class(value)

        value_class = value.class
        if Hash == value_class
          value = fix_hash(value)
        elsif Array == value_class
          value = value.map { |v| fix_value(v) }
        elsif value.respond_to?(:to_h) && 0 == value.method(:to_h).arity
          value = value.to_h
          raise WAB::TypeError unless value.is_a?(Hash)
          value = fix(value)
        elsif value.respond_to?(:to_s)
          value = value.to_s
          raise StandardError.new('Data values must be either a Hash or an Array') unless value.is_a?(String)
        else
          raise WAB::TypeError, "#{value_class} is not a valid Data value."
        end
        value
      end

      def fix_hash(hsh)
        old = hsh
        hsh = {}
        old.each_pair { |k, v|
          k = k.to_sym unless k.is_a?(Symbol)
          hsh[k] = fix_value(v)
        }
        hsh
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

      def deep_dup_value(value)
        if value.is_a?(Hash)
          c = {}
          value.each_pair { |k, v| c[k] = deep_dup_value(v) }
        elsif value.is_a?(Array)
          c = value.map { |v| deep_dup_value(v) }
        else
          value_class = value.class
          c = if value.nil? ||
                  TrueClass  == value_class ||
                  FalseClass == value_class ||
                  Integer    == value_class ||
                  Float      == value_class ||
                  String     == value_class ||
                  WAB::Utils.pre_24_fixnum?(value)
                value
              else
                value.dup
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
          element = Data.detect_string(item)
          collection[key] = element unless element == item
        end
      end

    end # Data
  end # Impl
end # WAB
