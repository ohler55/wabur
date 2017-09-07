
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
        @loggable? = @shell.logger.info?
      end

      def do_GET(req, res)
        begin
          ctrl, path, query, _ =  extract_req(req)
          @shell.logger.info("controller.read(#{path.join('/')}#{query})") if @loggable?
          result = ctrl.read(path, query)
          send_result(ctrl.read(path, query), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_PUT(req, res)
        begin
          ctrl, path, query, body =  extract_req(req)
          @shell.logger.info("controller.create(#{path.join('/')}#{query}, #{body.json})") if @loggable?
          send_result(ctrl.create(path, query, body), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_POST(req, res)
        begin
          ctrl, path, query, body =  extract_req(req)
          @shell.logger.info("controller.update(#{path.join('/')}#{query}, #{body.json})") if @loggable?
          send_result(ctrl.update(path, query, body), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      def do_DELETE(req, res)
        begin
          ctrl, path, query, _ =  extract_req(req)
          @shell.logger.info("controller.delete(#{path.join('/')}#{query})") if @loggable?
          send_result(ctrl.delete(path, query), res)
        rescue Exception => e
          send_error(e, res)
        end
      end

      private

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
