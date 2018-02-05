
module WAB
  module Impl
    module Agoo
      
      # Handler for requests that fall under the path assigned to the
      # Controller. This is used only with the WAB::Impl::Shell.
      class Handler
	include Sender
	
	def initialize(shell, controller)
          @shell = shell
	  @controller = controller
	end

	def on_request(req, res)
	  path = (req.script_name + req.path_info).split('/')[1..-1]
	  query = parse_query(req.query_string)
          body = req.body
          unless body.nil?
	    if body.empty?
	      body = nil
	    else
              body = Data.new(Oj.strict_load(body, symbol_keys: true))
              body.detect
	    end
          end
	  case req.request_method
	  when 'GET'
	    @shell.log_call(@controller, 'read', path, query)
            send_result(@controller.read(path, query), res, path, query)
	  when 'PUT'
	    @shell.log_call(@controller, 'create', path, query, body)
            send_result(@controller.create(path, query, body), res, path, query)
	  when 'POST'
	    @shell.log_call(@controller, 'update', path, query, body)
            send_result(@controller.update(path, query, body), res, path, query)
	  when 'DELETE'
	    @shell.log_call(@controller, 'delete', path, query)
            send_result(@controller.delete(path, query), res, path, query)
	  else
	    raise StandardError.new("#{method} is not a supported method") if op.nil?
	  end
	rescue StandardError => e
          send_error(e, res)
	end

      end # Handler
    end # Agoo
  end # Impl
end # WAB
