
require 'wab'

module WAB

  module Impl

    # The shell for reference Ruby implementation.
    class Shell < ::WAB::Shell

      # Sets up the shell with a view, model, and type_key.
      def initialize(view, model, type_key='kind')
        super
      end

      # Create and return a new data instance with the provided initial value.
      # The value must be a Hash or Array. The members of the Hash or Array
      # must be nil, boolean, String, Integer, Float, BigDecimal, Array, Hash,
      # Time, URI::HTTP, or WAB::UUID. Keys to Hashes must be Symbols.
      #
      # If the repair flag is true then an attempt will be made to fix the
      # value by replacing String keys with Symbols and calling to_h or to_s
      # on unsupported Objects.
      #
      # value:: initial value
      # repair:: flag indicating invalid value should be repaired if possible
      def data(value={}, repair=false)
        Data.new(value, repair)
      end
      
    end # Shell
  end # Impl
end # WAB
