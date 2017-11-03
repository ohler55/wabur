
require 'webrick'

module WAB
  module Impl

    # Handler for requests that fall under the path assigned to the
    # Controller. This is used only with the WAB::Impl::Shell.
    class TqlHandler < WEBrick::HTTPServlet::AbstractServlet

      def initialize(server, shell)
        super(server)
        @shell = shell
      end

      def do_POST(req, res)
        path = req.path.split('/')[1..-1]
        query = {}
        req.query.each { |k,v| query[k.to_sym] = v }
        tql = Oj.load(req.body, mode: :wab)
        log_request_with_body('TQL', path, query, tql) if @shell.logger.info?
        send_result(@shell.query(tql), res, path, query)
      rescue StandardError => e
        send_error(e, res)
      end

      private

      def log_request_with_body(caller, path, query, body)
        @shell.logger.info("#{caller} #{path.join('/')}#{query}\n#{body.json(@shell.indent)}")
      end

      # Sends the results from a controller request.
      def send_result(result, res, path, query)
        result = @shell.data(result) unless result.is_a?(WAB::Data)
        response_body = result.json(@shell.indent)
        res.status = 200
        res['Content-Type'] = 'application/json'
        @shell.logger.debug("reply to #{path.join('/')}#{query}: #{response_body}") if @shell.logger.debug?
        res.body = response_body
      end

      # Sends an error from a rescued call.
      def send_error(e, res)
        res.status = 500
        res['Content-Type'] = 'application/json'
        body = { code: -1, error: "#{e.class}: #{e.message}" }
        body[:backtrace] = e.backtrace
        res.body = @shell.data(body).json(@shell.indent)
        @shell.logger.warn(Impl.format_error(e))
      end

    end # TqlHandler
  end # Impl
end # WAB
