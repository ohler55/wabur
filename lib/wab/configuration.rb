
require 'logger'

module WAB

  # Handles the configuration for a Shell Implementation and the Ruby Runner
  class Configuration
    DEFAULTS = {
      'handler'    => {
        'path' => '/v1'
      },
      'controller' => 'BasicController',
      'type_key'   => 'kind',
      'http'       => {
        'dir'  => 'view/pages',
        'port' => 6363
      },
      'verbose'    => Logger::WARN
    }.freeze

    class << self
      def from(file)
        DEFAULTS.merge(self.new(file).extract)
      end
    end

    def initialize(file)
      @file = file
    end

    def extract
      return DEFAULTS if @file.nil?

      # support nesting hashes upto three-levels deep only
      config = Hash.new do |hsh, key|
        hsh[key] = Hash.new do |h, k|
          h[k] = Hash.new(&:default_proc)
        end
      end

      File.open(File.expand_path(@file)) do |f|
        f.each_line do |line|
          line.strip!
          next if line.empty? || line.start_with?('#')
          key, value = line.split('=').map(&:strip)

          keys = key.split(".")
          primary_key = keys.shift
          if keys.empty?
            config[primary_key] = value
          else
            secondary_key = keys.shift
            if keys.empty?
              config[primary_key][secondary_key] = value
            else
              tertiary_key = keys.shift
              if keys.empty?
                config[primary_key][secondary_key][tertiary_key] = value
              end
            end
          end
        end
      end
      config
    end

  end # Configuration
end # WAB
