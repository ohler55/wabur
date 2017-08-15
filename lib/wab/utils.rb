module WAB
  module Utils
    class << self
      def RUBY_SERIES
        RbConfig::CONFIG.values_at("MAJOR", "MINOR").join.to_i
      end
    end
  end
end
