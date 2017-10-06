
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
        types      = config[:rest]
        config_dir = "#{path}/config"
        lib_dir    = "#{path}/lib"

        raise WAB::Error.new('At least one record type is required for new or init.') if types.nil? || types.empty?

        @verbose = config[:verbosity]
        @verbose = 'INFO' == @verbose || 'DEBUG' == @verbose

        FileUtils.mkdir_p([config_dir,lib_dir])

        write_ui_controllers(lib_dir, types)
        write_spawn(lib_dir, types)

        write_wabur_conf(config_dir, types)
        write_opo_conf(config_dir, types)
        write_opo_rub_conf(config_dir, types)

        copy_site(File.expand_path("#{__dir__}/../../../export"), "#{path}/site") if config[:site]

      rescue StandardError => e
        # TBD: Issue more helpful error message
        puts %|*-*-* #{e.class}: #{e.message}\n      #{e.backtrace.join("\n      ")}|
          abort
      end

      def write_ui_controllers(dir, types)
        rest_flows = ''
        types.each { |type|
          rest_flows << %|
    add_flow(WAB::UI::RestFlow.new(shell,
                                   {
                                     kind: '#{type}',
                                   }, ['$ref']))|
        }
        write_file(dir, 'ui_controller.rb', { rest_flows: rest_flows })
      end

      def write_spawn(dir, types)
        controllers = ''
        types.each { |type|
          controllers << %|
shell.register_controller('#{type}', WAB::OpenController.new(shell))|
        }
        write_file(dir, 'spawn.rb', { controllers: controllers })
      end

      def write_wabur_conf(dir, types)
        handlers = ''
        types.each_index { |index|
          handlers << %|
handler.#{index + 1}.type = #{types[index]}
handler.#{index + 1}.handler = WAB::OpenController|
        }
        write_file(dir, 'wabur.conf', { handlers: handlers })
      end

      def write_opo_conf(dir, _types)
        write_file(dir, 'opo.conf')
      end

      def write_opo_rub_conf(dir, types)
        handlers = ''
        types.each_index { |index|
          type = types[index]
          handlers << %|
handler.#{type.downcase}.path = /v1/#{type}/**
handler.#{type.downcase}.class = WAB::OpenController
|
        }
        write_file(dir, 'opo-rub.conf', { handlers: handlers })
      end

      def copy_site(src, dest)
        FileUtils.mkdir_p([dest])
        Dir.foreach(src) { |filename|
          next if filename.start_with?('.')
          src_path = "#{src}/#{filename}"
          dest_path = "#{dest}/#{filename}"

          if File.directory?(src_path)
            copy_site(src_path, dest_path)
          elsif File.file?(src_path)
            if File.exist?(dest_path)
              puts "#{dest_path} already exists." if @verbose
              next
            end
            out = `cp #{src_path} #{dest_path}`
            if out.empty?
              puts "#{dest_path} copied." if @verbose
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
          puts "#{filepath} already exists." if @verbose
        else
          template = File.open("#{__dir__}/templates/#{filename}.template", 'rb') { |f| f.read }
          content  = gsub_data.nil? ? template : template % gsub_data
          File.open(filepath, 'wb') { |f| f.write(content) }
          puts "#{filepath} written." if @verbose
        end
      end

    end # Init
  end # Impl
end # WAB
