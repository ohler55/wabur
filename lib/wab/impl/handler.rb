
require 'webrick'
require 'wab'

module WAB
  module Impl

    # Handler for requests that fall under the path assigned to the
    # Controller. This is used only with the ::WAB::Impl::Shell.
    class Handler < WEBrick::HTTPServlet::AbstractServlet

      def initialize(server, shell)
        super(server)
        @shell = shell
      end

      def do_GET(req, res)
        handle('GET', req, res)
      end

      def do_PUT(req, res)
        handle('PUT', req, res)
      end

      def do_POST(req, res)
        handle('POST', req, res)
      end

      def do_DELETE(req, res)
        handle('DELETE', req, res)
      end

      private

      # core function that handles the commonly-used HTTP methods:
      # GET, PUT, POST, DELETE
      def handle(method, request, response)
        controller, path, query, body = extract_req(request)
        log_response(caller(method), path, query, body) if @shell.logger.info?
        send_result(
          compute_result(method, controller, path, query, body), response
        )
      rescue StandardError => e
        send_error(e, response)
      end

      # Return caller strings for logger message, based on the HTTP method
      def caller(method)
        if method == 'GET'
          'controller.read'
        elsif method == 'PUT'
          'controller.create'
        elsif method == 'POST'
          'controller.update'
        elsif method == 'DELETE'
          'controller.delete'
        end
      end

      def log_response(caller, path, query, body=nil)
        msg = if body.nil?
                "#{caller}(#{path.join('/')}#{query})"
              else
                "#{caller}(#{path.join('/')}#{query}, #{body.json})"
              end

        @shell.logger.info(msg)
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
          body.detect()
        end
        [@shell.path_controller(path), path, query, body]
      end

      # Formulate results from the controller
      def compute_result(method, controller, path, query, body=nil)
        if method == 'GET'
          controller.read(path, query)
        elsif method == 'PUT'
          controller.create(path, query, body)
        elsif method == 'POST'
          controller.update(path, query, body)
        elsif method == 'DELETE'
          controller.delete(path, query)
        end
      end

      # Sends the results from a controller request.
      def send_result(result, res)
        result = @shell.data(result) unless result.is_a?(::WAB::Data)
        res.status = 200
        res['Content-Type'] = 'application/json'
        @shell.logger.debug("Reply: #{result.json}") if @shell.logger.debug?
        res.body = result.json
      end

      # Sends an error from a rescued call.
      def send_error(e, res)
        res.status = 500
        res['Content-Type'] = 'application/json'
        body = { code: -1, error: "#{e.class}: #{e.message}" }
        body[:backtrace] = e.backtrace
        res.body = @shell.data(body).json
        @shell.logger.warn(%|*-*-* #{e.class}: #{e.message}\n      #{e.backtrace.join("\n      ")}|)
      end

    end # Handler
  end # Impl
end # WAB
