
module WAB
  module Impl
    module Agoo

      # A handler that provides missing files in an assets directory where the
      # files are the wab and wab UI files.
      class ExportProxy
	include Sender

	def initialize(shell)
          @shell = shell
	end

	def on_request(req, res)
	  path = (req.script_name + req.path_info)
	  query = parse_query(req.query_string)
          path = '/index.html' if '/' == path
          mime = nil
          index = path.rindex('.')
          unless index.nil?
	    mime = {
	      'css' => 'text/css',
	      'eot' => 'application/vnd.ms-fontobject',
	      'es5' => 'application/javascript',
	      'es6' => 'application/javascript',
	      'gif' => 'image/gif',
	      'html' => 'text/html',
	      'ico' => 'image/x-icon',
	      'jpeg' => 'image/jpeg',
	      'jpg' => 'image/jpeg',
	      'js' => 'application/javascript',
	      'json' => 'application/json',
	      'png' => 'image/png',
	      'sse' => 'text/plain',
	      'svg' => 'image/svg+xml',
	      'ttf' => 'application/font-sfnt',
	      'txt' => 'text/plain',
	      'woff' => 'application/font-woff',
	      'woff2' => 'font/woff2',
	    }[path[index + 1..-1].downcase]
          end
          mime = 'text/plain' if mime.nil?
          content = WAB.get_export(path)
          res.code = 200
          res['Content-Type'] = mime
          res.body = content
        rescue Exception => e
          send_error(e, res)
        end
	
      end # ExportProxy
    end # Agoo
  end # Impl
end # WAB
