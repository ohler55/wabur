
require 'wab/impl/pathexpr'

module WAB
  module Impl

    class Regex < PathExpr
      def initialize(path, rx)
        super(path)
        if rx.is_a?(Regexp)
          @rx = rx
        else
          @rx = Regexp.new(rx.to_s)
        end
      end

      def eval(data)
        value = data.get(@path)
        return !@rx.match(value).nil? if value.is_a?(String)
        false
      end

      def native()
        ['REGEX', @path, @rx.source]
      end

    end # Regex
  end # Impl
end # WAB
