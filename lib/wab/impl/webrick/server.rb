
require 'webrick'

module WAB
  module Impl
    module WEBrick

      # The Server module provides a server start method.
      module Server

	# Start the WEBrick server and set the mount points.
	def self.start(shell)
          mime_types = ::WEBrick::HTTPUtils::DefaultMimeTypes
          mime_types['es6'] = 'application/javascript'
          server = ::WEBrick::HTTPServer.new(Port: shell.http_port,
                                             DocumentRoot: shell.http_dir,
                                             MimeTypes: mime_types)
          server.logger.level = 5 - shell.logger.level unless shell.logger.nil?

          shell.mounts.each { |hh|
	    if hh.has_key?(:type)
              server.mount("#{shell.pre_path}/#{hh[:type]}", WAB::Impl::WEBrick::Handler, shell, shell.create_controller(hh[:handler]), false)
	    elsif hh.has_key?(:path)
              server.mount(hh[:path], WAB::Impl::WEBrick::Handler, shell, shell.create_controller(hh[:handler]), true)
	    else
              raise WAB::Error.new("Invalid handle configuration. Missing path or type.")
	    end
	  }
          server.mount(shell.tql_path, TqlHandler, shell) unless (shell.tql_path.nil? || shell.tql_path.empty?)
          server.mount('/', ExportProxy, shell.http_dir) if shell.export_proxy

          trap 'INT' do server.shutdown end
          server.start
	end

      end # Server
    end # WEBrick
  end # Impl
end # WAB
