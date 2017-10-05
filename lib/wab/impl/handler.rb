
require 'webrick'

module WAB
  module Impl

    # Handler for requests that fall under the path assigned to the
    # Controller. This is used only with the WAB::Impl::Shell.
    class Handler < WEBrick::HTTPServlet::AbstractServlet

      def initialize(server, shell)
        super(server)
        @shell = shell
      end

      def do_GET(req, res)
        controller, path, query = extract_req(req)
        log_request('controller.read', path, query) if @shell.logger.info?
        send_result(controller.read(path, query), res, path, query)
      rescue StandardError => e
        send_error(e, res)
      end

      def do_PUT(req, res)
        controller, path, query, body = extract_req(req)
        log_request_with_body('controller.create', path, query, body) if @shell.logger.info?
        send_result(controller.create(path, query, body), res, path, query)
      rescue StandardError => e
        send_error(e, res)
      end

      def do_POST(req, res)
        controller, path, query, body = extract_req(req)
        log_request_with_body('controller.update', path, query, body) if @shell.logger.info?
        send_result(controller.update(path, query, body), res, path, query)
      rescue StandardError => e
        send_error(e, res)
      end

      def do_DELETE(req, res)
        controller, path, query = extract_req(req)
        log_request('controller.delete', path, query) if @shell.logger.info?
        send_result(controller.delete(path, query), res, path, query)
      rescue StandardError => e
        send_error(e, res)
      end

      private

      def log_request(caller, path, query)
        @shell.logger.info("#{caller}(#{path.join('/')}#{query})")
      end

      def log_request_with_body(caller, path, query, body)
        @shell.logger.info("#{caller}(#{path.join('/')}#{query}, #{body.json})")
      end

      # Pulls and converts the request path, query, and body. Also returns the
      # controller.
      def extract_req(req)
        path = req.path.split('/')[1..-1]
        query = {}
        req.query.each { |k,v| query[k.to_sym] = v }
        if req.body.nil?
          body = nil
        else
          body = Oj.strict_load(req.body, symbol_keys: true)
          body = Data.new(body, false)
          body.detect
        end
        [@shell.path_controller(path), path, query, body]
      end

      # Sends the results from a controller request.
      def send_result(result, res, path, query)
        result = @shell.data(result) unless result.is_a?(WAB::Data)
        res.status = 200
        res['Content-Type'] = 'application/json'
        @shell.logger.debug("reply to #{path.join('/')}#{query}: #{result.json(@shell.indent)}") if @shell.logger.debug?
        res.body = result.json(@shell.indent)
      end

      # Sends an error from a rescued call.
      def send_error(e, res)
        res.status = 500
        res['Content-Type'] = 'application/json'
        body = { code: -1, error: "#{e.class}: #{e.message}" }
        body[:backtrace] = e.backtrace
        res.body = @shell.data(body).json(@shell.indent)
        @shell.logger.warn(%|*-*-* #{e.class}: #{e.message}\n      #{e.backtrace.join("\n      ")}|)
      end

    end # Handler
  end # Impl
end # WAB
