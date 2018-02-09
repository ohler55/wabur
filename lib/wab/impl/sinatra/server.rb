
require 'sinatra/base'

module WAB
  module Impl
    module Sinatra

      # The Server module provides a server start method.
      class Server < ::Sinatra::Application

	# Start the server and set the mount points.
	def self.start(shell)
	  set(:port, shell.http_port)
	  set(:public_folder, 'public')
	  set(:public_folder, File.expand_path(shell.http_dir))
	  set(:static, true)
	  set(:logging, shell.logger.info?)

          shell.mounts.each { |hh|
	    if hh.has_key?(:type)
	      handler = WAB::Impl::Sinatra::Handler.new(shell, shell.create_controller(hh[:handler]))
	      path = "#{shell.pre_path}/#{hh[:type]}"

	      get(path) { handler.wab_call(request) }
	      get(path+'/*') { handler.wab_call(request) }

	      put(path) { handler.wab_call(request) }
	      put(path+'/*') { handler.wab_call(request) }

	      post(path) { handler.wab_call(request) }
	      post(path+'/*') { handler.wab_call(request) }

	      delete(path) { handler.wab_call(request) }
	      delete(path+'/*') { handler.wab_call(request) }

	    elsif hh.has_key?(:path)
	      path = hh[:path]
	      if path.empty?
		path = '/**'
	      elsif  '*' != path[-1]
		path << '/' unless '/' == path[-1]
		path << '**'
	      end
	      controller = shell.create_controller(hh[:handler])
	      post(path) { controller.call(request.env) }
	    else
              raise WAB::Error.new("Invalid handle configuration. Missing path or type.")
	    end
	  }
	  unless (shell.tql_path.nil? || shell.tql_path.empty?)
	    tql_handler = WAB::Impl::Sinatra::TqlHandler.new(shell)
	    post('/tql') { tql_handler.call(request) }
	  end
	  if shell.export_proxy
            exporter = WAB::Impl::Sinatra::ExportProxy.new(shell)
	    get('/**') { exporter.call(request) }
	  end

          trap 'INT' do server.shutdown end
	  run!
	end

      end # Server
    end # Sinatra
  end # Impl
end # WAB
