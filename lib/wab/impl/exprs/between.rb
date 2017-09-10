
module WAB
  module Impl

    # Matches numeric nodes between a minimum and maximum value. By default
    # the matches are inclusive of the minimum and maximum. The optional
    # arguments allow the inclusivity to be changed to exclusive separately
    # for the minimum and maximum. By default the min_incl and max_incl are
    # true. If set to false the corresponding limit becomes exclusive. An
    # error is returned if used with non-numeric minimum or maximum.
    class Between < PathExpr

      # Creates a new instance with the provided parameters.
      #
      # path:: path to the value to compare
      # min:: minimum
      # max:: maximum
      # min_incl:: minimum inclusive flag
      # max_incl:: maximum inclusive flag
      def initialize(path, min, max, min_incl=true, max_incl=true)
        super(path)
        @min = min
        @max = max
        @min_incl = min_incl
        @max_incl = max_incl
      end

      def eval(data)
        value = data.get(@path)
        return false if (@min_incl ? value < @min : value <= @min)
        return false if (@max_incl ? @max < value : @max <= value)
        true
      end

      def native()
        ['BETWEEN', @path, @min, @max, @min_incl, @max_incl]
      end

    end # Between
  end # Impl
end # WAB
