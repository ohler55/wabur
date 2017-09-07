
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
        ctrl, path, query = extract_req(req)
        log_response('controller.read', path, query) if @shell.logger.info?
        send_result(compute_result('GET', ctrl, path, query), res)
      rescue Exception => e
        send_error(e, res)
      end

      def do_PUT(req, res)
        ctrl, path, query, body = extract_req(req)
        log_response('controller.create', path, query, body) if @shell.logger.info?
        send_result(compute_result('PUT', ctrl, path, query, body), res)
      rescue Exception => e
        send_error(e, res)
      end

      def do_POST(req, res)
        ctrl, path, query, body = extract_req(req)
        log_response('controller.update', path, query, body) if @shell.logger.info?
        send_result(compute_result('POST', ctrl, path, query, body), res)
      rescue Exception => e
        send_error(e, res)
      end

      def do_DELETE(req, res)
        ctrl, path, query = extract_req(req)
        log_response('controller.delete', path, query) if @shell.logger.info?
        send_result(compute_result('DELETE', ctrl, path, query), res)
      rescue Exception => e
        send_error(e, res)
      end

      private

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

      def compute_result(method, ctrl, path, query, body=nil)
        if method == 'GET'
          ctrl.read(path, query)
        elsif method == 'PUT'
          ctrl.create(path, query, body)
        elsif method == 'POST'
          ctrl.update(path, query, body)
        elsif method == 'DELETE'
          ctrl.delete(path, query)
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
