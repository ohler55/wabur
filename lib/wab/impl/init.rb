
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
          types = config[:rest]

          config_dir = "#{path}/config"
          FileUtils.mkdir_p(config_dir)

          lib_dir = "#{path}/lib"
          FileUtils.mkdir_p(lib_dir)

          write_ui_controllers(lib_dir, types)
          write_wabur_conf(config_dir, types)
          write_opo_conf(config_dir, types)
          write_opo_rub_conf(config_dir, types)

        rescue StandardError => e
          puts "*-*-* #{e.class}: #{e.message}"
        end

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
          template = File.open("#{__dir__}/templates/ui_controller.rb.template") { |f| f.read }
          File.open("#{dir}/ui_controller.rb", 'w') { |f|
            rest_flows = ''
            types.each { |type|
              rest_flows << %|
    add_flow(WAB::UI::RestFlow.new(shell,
                                   {
                                     kind: '#{type}',
                                   }, ['$ref']))
|
            }
            f.write(template % { rest_flows: rest_flows })
          }
        end
        
        def write_wabur_conf(dir, types)
          template = File.open("#{__dir__}/templates/wabur.conf.template") { |f| f.read }
          File.open("#{dir}/wabur.conf", 'w') { |f|
            handlers = ''
            types.each_index { |index|
              handlers << %|
handler.#{index + 1}.type = #{types[index]}
handler.#{index + 1}.handler = WAB::OpenController
|
            }
            f.write(template % { handlers: handlers })
          }
        end
        
        def write_opo_conf(dir, types)
          template = File.open("#{__dir__}/templates/opo.conf.template") { |f| f.read }
          File.open("#{dir}/opo.conf", 'w') { |f|
            f.write(template)
          }
        end
        
        def write_opo_rub_conf(dir, types)
          template = File.open("#{__dir__}/templates/opo-rub.conf.template") { |f| f.read }
          File.open("#{dir}/opo-rub.conf", 'w') { |f|
            handlers = ''
            types.each_index { |index|
              type = types[index]
              handlers << %|
handler.#{type.downcase}.path = /v1/#{type}/**
handler.#{type.downcase}.class = WAB::OpenController
|
            }
            f.write(template % { handlers: handlers })
          }
        end

      end # self
    end # Init
  end # Impl
end # WAB
      
