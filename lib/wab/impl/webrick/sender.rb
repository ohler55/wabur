
require 'webrick'

module WAB
  module Impl
    module WEBrick

      # The Sender module adds support for sending results and errors.
      module Sender

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

      end # Sender
    end # WEBrick
  end # Impl
end # WAB
