
require 'sinatra'

module WAB
  module Impl
    module Sinatra

      # The Server module provides a server start method.
      module Server

	# Start the server and set the mount points.
	def self.start(shell)
	  ::Sinatra::Base.get('/') { 'hello' }
=begin	  
	  server = ::Sinatra::Server.new(shell.http_port, shell.http_dir, options)

          shell.mounts.each { |hh|
	    if hh.has_key?(:type)
	      handler = WAB::Impl::Sinatra::Handler.new(shell, shell.create_controller(hh[:handler]))
              server.handle(nil, "#{shell.pre_path}/#{hh[:type]}", handler)
              server.handle(nil, "#{shell.pre_path}/#{hh[:type]}/*", handler)
	    elsif hh.has_key?(:path)
	      path = hh[:path]
	      if path.empty?
		path = '/**'
	      elsif  '*' != path[-1]
		path << '/' unless '/' == path[-1]
		path << '**'
	      end
              server.handle(:POST, path, shell.create_controller(hh[:handler]))
	    else
              raise WAB::Error.new("Invalid handle configuration. Missing path or type.")
	    end
	  }
          server.handle(:POST, shell.tql_path, WAB::Impl::Sinatra::TqlHandler.new(shell)) unless (shell.tql_path.nil? || shell.tql_path.empty?)
          server.handle_not_found(WAB::Impl::Sinatra::ExportProxy.new(shell)) if shell.export_proxy
=end
          trap 'INT' do server.shutdown end
	  # add options
	  ::Sinatra::Base.run!
	end

      end # Server
    end # Sinatra
  end # Impl
end # WAB
