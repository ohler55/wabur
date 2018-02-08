
module WAB
  module Impl
    module Sinatra
      
      # Handler for requests that fall under the path assigned to the
      # Controller. This is used only with the WAB::Impl::Shell.
      class Handler
	include Sender
	
	def initialize(shell, controller)
          @shell = shell
	  @controller = controller
	end

	def wab_call(req)
	  path = (req.script_name + req.path_info).split('/')[1..-1]
	  query = parse_query(req.query_string)
          body = nil
          unless req.body.nil?
	    content = req.body.read
	    unless content.empty?
              body = Data.new(Oj.strict_load(content, symbol_keys: true))
              body.detect
	    end
          end
	  case req.request_method
	  when 'GET'
	    @shell.log_call(@controller, 'read', path, query)
            send_result(@controller.read(path, query), path, query)
	  when 'PUT'
	    @shell.log_call(@controller, 'create', path, query, body)
            send_result(@controller.create(path, query, body), path, query)
	  when 'POST'
	    @shell.log_call(@controller, 'update', path, query, body)
            send_result(@controller.update(path, query, body), path, query)
	  when 'DELETE'
	    @shell.log_call(@controller, 'delete', path, query)
            send_result(@controller.delete(path, query), path, query)
	  else
	    raise StandardError.new("#{method} is not a supported method") if op.nil?
	  end
	rescue StandardError => e
	  send_error(e)
	end

      end # Handler
    end # Sinatra
  end # Impl
end # WAB
