
require 'webrick'

module WAB
  module Impl
    module WEBrick

      # The Sender module adds support for sending results and errors.
      module Sender

	def log_call(op, path, query, body=nil)
	  if @shell.logger.debug?
	    if body.nil? || body.empty?
	      @shell.logger.debug("#{@controller.class}.#{op}(#{path_to_s(path)}#{query})")
	    else
	      body = body.json(@shell.indent) unless body.is_a?(String)
	      @shell.logger.debug("#{@controller.class}.#{op}(#{path_to_s(path)}#{query})\n#{body}")
	    end
	  elsif @shell.logger.info?
	    @shell.logger.info("#{@controller.class}.#{op}(#{path_to_s(path)}#{query})") if @shell.logger.info?
	  end
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

	private
	
	def path_to_s(path)
	  if path.is_a?(String)
	    path
	  else
	    path.join('/')
	  end
	end
	
      end # Sender
    end # WEBrick
  end # Impl
end # WAB
