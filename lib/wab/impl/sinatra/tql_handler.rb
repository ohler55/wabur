
module WAB
  module Impl
    module Sinatra

      # Handler for requests that fall under the path assigned to the
      # Controller. This is used only with the WAB::Impl::Shell.
      class TqlHandler
	include Sender

	def initialize(shell)
          @shell = shell
	end

	def call(req)
	  path = (req.script_name + req.path_info).split('/')[1..-1]
	  query = parse_query(req.query_string)
          tql = Oj.load(req.body, mode: :wab)
          log_request_with_body('TQL', path, query, tql) if @shell.logger.info?
          send_result(@shell.query(tql), path, query)
	rescue StandardError => e
          send_error(e, res)
	end

	private

	def log_request_with_body(caller, path, query, body)
          body = Data.new(body) unless body.is_a?(WAB::Data)
          @shell.logger.info("#{caller} #{path.join('/')}#{query}\n#{body.json(@shell.indent)}")
	end

      end # TqlHandler
    end # Sinatra
  end # Impl
end # WAB
