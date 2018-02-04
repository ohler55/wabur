
require 'webrick'

module WAB
  module Impl
    module WEBrick
      
      # Handler for requests that fall under the path assigned to the
      # Controller. This is used only with the WAB::Impl::Shell.
      class Handler < ::WEBrick::HTTPServlet::AbstractServlet
	include Sender
	
	def initialize(server, shell, controller, is_rack)
          super(server)
          @shell = shell
	  @controller = controller
	  @is_rack = is_rack
	end

	def service(req, res)
	  if @is_rack
	    rack_call(req, res)
	  else
            path, query, body = extract_path_query(req)
	    case req.request_method
	    when 'GET'
	      log_call('read', path, query)
              send_result(@controller.read(path, query), res, path, query)
	    when 'PUT'
	      log_call('create', path, query, body)
              send_result(@controller.create(path, query, body), res, path, query)
	    when 'POST'
	      log_call('update', path, query, body)
              send_result(@controller.update(path, query, body), res, path, query)
	    when 'DELETE'
	      log_call('delete', path, query)
              send_result(@controller.delete(path, query), res, path, query)
	    else
	      raise StandardError.new("#{method} is not a supported method") if op.nil?
	    end
	  end
	rescue StandardError => e
          send_error(e, res)
	end

	private

	def rack_call(req, res)
	  env = {
	    'REQUEST_METHOD' => req.request_method,
	    'SCRIPT_NAME' => req.script_name,
	    'PATH_INFO' => req.path_info,
	    'QUERY_STRING' => req.query_string,
	    'SERVER_NAME' => req.server_name,
	    'SERVER_PORT' => req.port,
	    'rack.version' => '1.2',
	    'rack.url_scheme' => req.ssl? ? 'https' : 'http',
	    'rack.errors' => WAB::Impl::RackError.new(@shell),
	    'rack.multithread' => false,
	    'rack.multiprocess' => false,
	    'rack.run_once' => false,
	  }
	  log_call('call', req.script_name + req.path_info, req.query_string, req.body)
	  req.each { |k| env['HTTP_' + k] = req[k] }
	  env['rack.input'] = StringIO.new(req.body) unless req.body.nil?
	  rres = @controller.call(env)
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

	# Pulls and converts the request path, query, and body.
	def extract_path_query(req)
          path = req.path.split('/')[1..-1]
          query = {}
          if !req.query_string.nil? && !req.query_string.empty? && req.query.empty?
            # WEBRick does not parse queries on PUT and some others so do it
            # manually.
            req.query_string.split('&').each { |opt|
              k, v = opt.split('=')
              # TBD convert %xx to char
              query[k] = v
            }
          else
            req.query.each { |k,v| query[k.to_sym] = v }
          end
          # Detect numbers (others later)
          query.each_pair { |k,v|
            i = Utils.attempt_key_to_int(v)
            query[k] = i unless i.nil?
            # TBD how about float
          }
          request_body = req.body
          if request_body.nil?
            body = nil
          else
            body = Data.new(
              Oj.strict_load(request_body, symbol_keys: true)
            )
            body.detect
          end
          [path, query, body]
	end

      end # Handler
    end # WEBrick
  end # Impl
end # WAB
