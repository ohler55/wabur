
require 'webrick'

module WAB
  module Impl
    module WEBrick

      # A handler that provides missing files in an assets directory where the
      # files are the wab and wab UI files.
      class ExportProxy < ::WEBrick::HTTPServlet::FileHandler

	def initialize(server, path)
          super
	end

	def do_GET(req, res)
          super
	rescue Exception => e
          path = req.path
          path = '/index.html' if '/' == path
          begin
            mime = nil
            index = path.rindex('.')
            unless index.nil?
              mime = WEBrick::HTTPUtils::DefaultMimeTypes[path[index + 1..-1]]
            end
            mime = 'text/plain' if mime.nil?
            content = WAB.get_export(path)
            res.status = 200
            res['Content-Type'] = mime
            res.body = content
          rescue Exception
            # raise the original error for a normal not found error
            raise e
          end
	end
	
      end # ExportProxy
    end # WEBrick
  end # Impl
end # WAB
