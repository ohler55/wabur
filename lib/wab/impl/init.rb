
require 'fileutils'

module WAB
  module Impl

    # Creates the initial files for a project including the configuration
    # files and a UI controller. The files are:
    # - config/wabur.conf
    # - config/opo.conf
    # - config/opo-rub.conf
    # - lib/uicontroller.rb
    class Init

      class << self
        def setup(path, config)
          exist_check(path)

          types      = config[:rest]
          config_dir = "#{path}/config"
          lib_dir    = "#{path}/lib"

          FileUtils.mkdir_p([config_dir,lib_dir])

          write_ui_controllers(lib_dir, types)
          write_spawn(lib_dir, types)

          write_wabur_conf(config_dir, types)
          write_opo_conf(config_dir, types)
          write_opo_rub_conf(config_dir, types)

        rescue StandardError => e
          puts "*-*-* #{e.class}: #{e.message}"
        end

        private

        def exist_check(path)
          [
           'config/wabur.conf',
           'config/opo.conf',
           'config/opo-rub.conf',
           'lib/ui_controller.rb',
          ].each { |filename|
            fullpath = "#{path}/#{filename}"
            raise WAB::DuplicateError.new(fullpath) if File.exist?(fullpath)
          }
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

        def write_file(dir, filename, gsub_data=nil)
          template = File.open("#{__dir__}/templates/#{filename}.template", 'rb') { |f| f.read }
          content  = gsub_data.nil? ? template : template % gsub_data
          File.open("#{dir}/#{filename}", 'wb') { |f| f.write(content) }
        end

      end # self
    end # Init
  end # Impl
end # WAB
