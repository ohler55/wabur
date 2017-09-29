# frozen_string_literal: true

require 'optparse'
require 'logger'

module WAB
  module Impl

    # Handles the configuration for a Shell Implementation and the Ruby Runner
    class Configuration

      attr_accessor :map
      
      def initialize(usage, options)
        @map = {}
        opts = OptionParser.new(usage)
        config_file = nil
        log_level = Logger::WARN
        
        opts.on('-c', '--config PATH', String, 'Configuration file.') { |c| config_file = c }
        opts.on('-r', '--require LIBRARY', String, 'Require.')        { |r| require r }
        opts.on('-v', '--verbose', 'Increase verbosity.')             { log_level += 1 }
        opts.on('-h', '--help', 'Show this display.')                 { puts opts.help; Process.exit!(0) }

        # Process command-line arguments and append them, in order, to an empty hash @map
        add_options(opts, options)

        modes = opts.parse(ARGV)
        @map[:mode] = 0 < modes.length ? modes[0] : 'run'
        @map[:rest] =  modes[1..-1] if 1 < modes.length

        unless ['run', 'new', 'init'].include?(@map[:mode])
          puts "\n*-*-* #{@map[:mode]} is not a valid mode"
          puts opts.help
          Process.exit!(-1)
        end

        # Move the @map sideways and replace with defaults.
        command_line_map = @map
        @map = {}
        build_default_map(options)

        # If a config file was specified load it and merge into @map.
        @map = merge_map(@map, parse_config_file(config_file)) unless config_file.nil?

        # Merge in the command line map.
        @map = merge_map(@map, command_line_map) unless command_line_map.empty?
      end

      # Walks the options map and calls +opts.on+ for each option so that all
      # are provided when +--help+ is called.
      def add_options(opts, options, path='')
        options.each_pair { |k,v|
          next unless v.is_a?(Hash)
          key_path = path.empty? ? k.to_s : "#{path}.#{k}"
          if v.has_key?(:val)
            default = v[:val]
            if default.is_a?(Array)
              if v.has_key?(:short)
                opts.on(v[:short], "--#{key_path} #{v[:arg]}", String, v[:doc]) { |val| arg_append(key_path, val, v[:parse]) }
              else
                opts.on("--#{key_path} #{v[:arg]}", String, v[:doc]) { |val| arg_append(key_path, val, v[:parse]) }
              end
            elsif v.has_key?(:short)
              opts.on(v[:short], "--#{key_path} #{v[:arg]}", v[:type], "#{v[:doc]} Default: #{default}") { |val| set(key_path, val) }
            else 
              opts.on("--#{key_path} #{v[:arg]}", v[:type], "#{v[:doc]} Default: #{default}") { |val| set(key_path, val) }
            end
          else
            add_options(opts, v, key_path)
          end
        }
      end

      # Appends an arg to an array in the configuration.
      def arg_append(path, val, parse)
        parts = val.split('=')
        if 1 < parts.length
          val = {}
          parse.each_index { |i| val[parse[i].to_sym] = parts[i] }
        end
        a = get(path)
        if a.nil?
          a = []
          set(path, a)
        end
        a.push(val)
      end

      # Builds a map from the default options passed in.
      def build_default_map(options, path='')
        options.each_pair { |k,v|
          next unless v.is_a?(Hash)
          key_path = path.empty? ? k.to_s : "#{path}.#{k}"
          if v.has_key?(:val)
            set(key_path, v[:val])
          else
            build_default_map(v, key_path)
          end
        }
      end

      # Recursive merge of other into prime.
      def merge_map(prime, other)
        prime.merge(other) { |key,prime_value,other_value|
          case prime_value
          when Hash
            merge_map(prime_value, other_value)
          when Array
            prime_value + other_value
          else
            other_value
          end
        }
      end
      
      # Returns a Hash of configuration data.
      #
      # TBD: Add validation to ensure only a Hash object is returned
      def parse_config_file(file)
        return {} unless File.exist?(file)

        case File.extname(file)
        when /\.conf$/i
          parse_conf_file(file)
        when /\.json$/i
          Oj.load_file(file, mode: :strict, symbol_keys: true)
        when /\.ya?ml$/i
          begin
            require 'safe_yaml/load'
            SafeYAML.load_file(file) || {}
          rescue LoadError
            # Re-raise with a more descriptive message. This should generally
            # abort the configuration loading.
            raise LoadError.new(%{Could not load the requested resource. Please install the 'safe_yaml' gem via
Bundler or directly, and try loading again.
})
          end
        end
      end

      # Returns a Hash containing data obtained by parsing a UNIX style conf
      # file.
      #
      # For example, +handler.sample.count = 63+ and +handler.sample.path = /v1+
      # will be parsed into the following:
      #
      #    { handler: { sample: { count: 63, path: "/v1" } } }
      def parse_conf_file(file)
        config = {}

        File.open(File.expand_path(file)) do |f|
          f.each_line do |line|
            line.strip!
            next if line.empty? || line.start_with?('#')
            key, value = line.split('=').map(&:strip)
            set_map(config, key, value)
          end
        end
        config
      end

      def set_map(node, path, value)
        return node if path.empty?
        Utils.set_value(node, path, value)
      end

      def set(path, value)
        set_map(@map, path, value)
      end
      alias []= set

      def get(path)
        Utils.get_node(@map, path)
      end
      alias [] get

    end # Configuration
  end # Impl
end # WAB
