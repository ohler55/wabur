
require 'webrick'

module WAB
  module Impl

    # Handler for requests that fall under the path assigned to the rack
    # Controller. This is used only with the WAB::Impl::Shell.
    class RackHandler < WEBrick::HTTPServlet::AbstractServlet

      def initialize(server, shell, handler)
        super(server)
        @shell = shell
        case handler
        when String
          handler = Object.const_get(handler).new(self)
        when Class
          handler = handler.new(self)
        end
        handler.shell = self
	@handler = handler
      end

      def service(req, res)
	env = {
	  'REQUEST_METHOD' => req.request_method,
	  'SCRIPT_NAME' => req.script_name,
	  'PATH_INFO' => req.path_info,
	  'QUERY_STRING' => req.query_string,
	  'SERVER_NAME' => req.server_name,
	  'SERVER_PORT' => req.port,
	  'rack.version' => '1.2',
	  'rack.url_scheme' => req.ssl? ? 'https' : 'http',
	  'rack.errors' => '', ## TBD
	  'rack.multithread' => false,
	  'rack.multiprocess' => false,
	  'rack.run_once' => false,
	}
	req.each { |k| env['HTTP_' + k] = req[k] }
	unless req.body.nil?
	  env['rack.input'] = StringIO.new(req.body)
	end
	rres = @handler.call(env)
        res.status = rres[0]
	rres[1].each { |a| res[a[0]] = a[1] }
	unless rres[2].empty?
	  res.body = ''
	  rres[2].each { |s| res.body << s }
	end
        @shell.logger.debug("reply to #{path.join('/')}#{query}: #{res.body}") if @shell.logger.debug?
      rescue StandardError => e
        send_error(e, res)
      end

      private

      # Sends an error from a rescued call.
      def send_error(e, res)
        res.status = 500
        res['Content-Type'] = 'application/json'
        body = { code: -1, error: "#{e.class}: #{e.message}" }
        body[:backtrace] = e.backtrace
        res.body = @shell.data(body).json(@shell.indent)
        @shell.logger.warn(Impl.format_error(e))
      end

    end # RackHandler
  end # Impl
end # WAB
