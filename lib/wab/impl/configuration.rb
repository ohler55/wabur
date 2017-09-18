# frozen_string_literal: true

require 'logger'

module WAB
  module Impl

    # Handles the configuration for a Shell Implementation and the Ruby Runner
    class Configuration
      DEFAULTS = {
        'base'       => '.',
        'data_dir'   => File.join('wabur', 'data'),
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
        def from(overrides = {})
          overrides['config_file'] ||= File.join('wabur', 'wabur.conf')
          overrides['base'] ||= DEFAULTS['base']

          DEFAULTS.merge(self.new.extract_config(
            File.expand_path(overrides.values_at('config_file', 'base').join)
          )).merge(overrides)
        end
      end

      # Returns a Hash of configuration data.
      #
      # TBD: Add validation to ensure only a Hash object is returned
      def extract_config(file)
        return {} unless File.exist?(file)

        case File.extname(file)
        when /\.conf/i
          parse_conf_file(file)
        when /\.json/i
          # TBD: Employ Oj or builtin JSON to load file.
        when /\.ya?ml/i
          begin
            require 'safe_yaml/load'
            SafeYAML.load_file(file) || {}
          rescue LoadError
            puts "Could not load the requested resource.\n" \
              "Please install the 'safe_yaml' gem via Bundler or directly, " \
              "and try loading again.."
            {}
          end
        end
      end

      # Returns a Hash containing data obtained by parsing a UNIX style conf
      # file. Currently, only a three-tier nesting is supported, while higher
      # tiers are silently ignored.
      #
      # For example, +handler.sample.count = 63+ and +handler.sample.path = /v1+
      # will be parsed into the following:
      #
      #    {"handler"=>{"sample"=>{"count"=>63, "path"=>"/v1"}}}
      #
      # but +handler.sample.path.node = Article+ will be ignored.
      def parse_conf_file(file)
        # support nesting hashes upto three-levels deep only
        config = Hash.new do |hsh, key|
          hsh[key] = Hash.new do |h, k|
            h[k] = Hash.new(&:default_proc)
          end
        end

        File.open(File.expand_path(file)) do |f|
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
  end # Impl
end # WAB
