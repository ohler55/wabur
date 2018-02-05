
require 'agoo'

module WAB
  module Impl
    module Agoo

      # The Server module provides a server start method.
      module Server

	# Start the server and set the mount points.
	def self.start(shell)
	  options = {
	    pedantic: false,
	    log_dir: '',
	    thread_count: 0,
	    log_console: true,
	    log_classic: true,
	    log_colorize: true,
	    log_states: {
	      INFO: shell.logger.info?,
	      DEBUG: shell.logger.debug?,
	      connect: shell.logger.info?,
	      request: shell.logger.info?,
	      response: shell.logger.info?,
	      eval: shell.logger.info?,
	    }
	  }
	  server = ::Agoo::Server.new(shell.http_port, shell.http_dir, options)

          # mime_types['es6'] = 'application/javascript'

          shell.mounts.each { |hh|
	    if hh.has_key?(:type)
	      handler = WAB::Impl::Agoo::Handler.new(shell, shell.create_controller(hh[:handler]))
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
          server.handle(:POST, shell.tql_path, WAB::Impl::Agoo::TqlHandler.new(shell)) unless (shell.tql_path.nil? || shell.tql_path.empty?)
	  # TBD use agoo default handler
          #server.handle(:GET, '/**', WAB::Impl::Agoo::ExportProxy.new(shell)) if shell.export_proxy

          trap 'INT' do server.shutdown end
          server.start
	end

      end # Server
    end # Agoo
  end # Impl
end # WAB
