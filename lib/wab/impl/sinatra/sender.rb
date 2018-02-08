
module WAB
  module Impl
    module Sinatra

      # The Sender module adds support for sending results and errors.
      module Sender

	# Sends the results from a controller request.
	def send_result(result, path, query)
          result = @shell.data(result) unless result.is_a?(WAB::Data)
          response_body = result.json(@shell.indent)
          @shell.logger.debug("reply to #{path.join('/')}#{query}: #{response_body}") if @shell.logger.debug?
	  [
	    200,
	    {'Content-Type' => 'application/json'},
	    [result.json(@shell.indent)]
	  ]
	end

	# Sends an error from a rescued call.
	def send_error(e)
          @shell.logger.warn(Impl.format_error(e))
          body = { code: -1, error: "#{e.class}: #{e.message}" }
          body[:backtrace] = e.backtrace
	  [ 500,
	    { 'Content-Type' => 'application/json' },
	    [ @shell.data(body).json(@shell.indent) ]
	  ]
	end

	# Parses a query string into a Hash.
	def parse_query(query_string)
	  query = {}
          if !query_string.nil? && !query_string.empty?
            query_string.split('&').each { |opt|
              k, v = opt.split('=')
              # TBD convert %xx to char
              query[k] = v
            }
          end
          # Detect numbers (others later)
          query.each_pair { |k,v|
            i = Utils.attempt_key_to_int(v)
            query[k] = i unless i.nil?
            # TBD how about float
          }
	end
	
      end # Sender
    end # Sinatra
  end # Impl
end # WAB
