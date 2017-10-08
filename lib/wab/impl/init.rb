
require 'fileutils'

module WAB
  module Impl

    # Creates the initial files for a project including the configuration
    # files and a UI controller. The files are:
    # - config/wabur.conf
    # - config/opo.conf
    # - config/opo-rub.conf
    # - lib/uicontroller.rb
    #
    # If the site option was set then all the export files are used to
    # populate a site directory as well.
    class Init

      def self.setup(path, config)
        self.new(path, config)
      end

      private

      def initialize(path, config)
        @types     = config[:rest] || []
        config_dir = "#{path}/config"
        lib_dir    = "#{path}/lib"
        init_site  = config[:site]

        if (@types.nil? || @types.empty?) && !init_site
          raise WAB::Error.new("At least one record type is required for 'new' or 'init'.")
        end

        @verbose = config[:verbosity]
        @verbose = 'INFO' == @verbose || 'DEBUG' == @verbose || Logger::INFO == @verbose || Logger::DEBUG == @verbose
        @write_cnt = 0
        @exist_cnt = 0
        @base_len = path.length + 1

        FileUtils.mkdir_p([config_dir, lib_dir])

        write_ui_controllers(lib_dir)
        write_spawn(lib_dir)

        write_wabur_conf(config_dir)
        write_opo_conf(config_dir)
        write_opo_rub_conf(config_dir)

        copy_site(File.expand_path("#{__dir__}/../../../export"), "#{path}/site") if init_site

        puts "Successfully initialized a WAB workspace at #{path}."
        puts "  Wrote #{@write_cnt} files." unless @write_cnt.zero?
        puts "  Skipped #{@exist_cnt} files that already existed" unless @exist_cnt.zero?

      rescue StandardError => e
        # TBD: Issue more helpful error message
        puts WAB::Impl.format_error(e)
        abort
      end

      def write_ui_controllers(dir)
        rest_flows = ''
        @types.each { |type|
          rest_flows << %|
    add_flow(WAB::UI::RestFlow.new(shell,
                                   {
                                     kind: '#{type}',
                                   }, ['$ref']))|
        }
        write_file(dir, 'ui_controller.rb', { rest_flows: rest_flows })
      end

      def write_spawn(dir)
        controllers = ''
        @types.each { |type|
          controllers << %|
shell.register_controller('#{type}', WAB::OpenController.new(shell))|
        }
        write_file(dir, 'spawn.rb', { controllers: controllers })
      end

      def write_wabur_conf(dir)
        handlers = ''
        @types.each_index { |index|
          natural_index = index + 1
          handlers << %|
handler.#{natural_index}.type = #{@types[index]}
handler.#{natural_index}.handler = WAB::OpenController|
        }
        write_file(dir, 'wabur.conf', { handlers: handlers })
      end

      def write_opo_conf(dir)
        write_file(dir, 'opo.conf')
      end

      def write_opo_rub_conf(dir)
        handlers = ''
        @types.each_index { |index|
          type = @types[index]
          slug = type.downcase
          handlers << %|
handler.#{slug}.path = /v1/#{type}/**
handler.#{slug}.class = WAB::OpenController
|
        }
        write_file(dir, 'opo-rub.conf', { handlers: handlers })
      end

      def copy_site(src, dest)
        FileUtils.mkdir_p(dest)
        Dir.foreach(src) { |filename|
          next if filename.start_with?('.')
          src_path = "#{src}/#{filename}"
          dest_path = "#{dest}/#{filename}"

          if File.directory?(src_path)
            copy_site(src_path, dest_path)
          elsif File.file?(src_path)
            if File.exist?(dest_path)
              puts "exists: #{dest_path[@base_len..-1]}" if @verbose
              @exist_cnt += 1
              next
            end
            out = `cp #{src_path} #{dest_path}`
            @write_cnt += 1
            if out.empty?
              puts "wrote:  #{dest_path[@base_len..-1]}" if @verbose
            else
              # the error message from the OS
              puts out
            end
          end
        }
      end

      def write_file(dir, filename, gsub_data=nil)
        filepath = "#{dir}/#{filename}"
        if File.exist?(filepath)
          puts "exists: #{filepath[@base_len..-1]}" if @verbose
          @exist_cnt += 1
        else
          template = File.open("#{__dir__}/templates/#{filename}.template", 'rb') { |f| f.read }
          content  = gsub_data.nil? ? template : template % gsub_data
          File.open(filepath, 'wb') { |f| f.write(content) }
          puts "wrote:  #{filepath[@base_len..-1]}" if @verbose
          @write_cnt += 1
        end
      end

    end # Init
  end # Impl
end # WAB
