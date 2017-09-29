
# Web Application Builder
module WAB

  # Returns a file contents from the gem export directory.
  def self.get_export(path)
    if path.nil? || path.empty?
      path = '/index.html'
    elsif !path.start_with?('/')
      path = "/#{path}"
    end
    raise ForbiddenError.new(path) if path.include?('..')
    path = File.expand_path("#{__dir__}/../export#{path}")
    File.open(path) { |f| f.read() }
  end

end

require 'wab/controller'
require 'wab/data'
require 'wab/errors'
require 'wab/open_controller'
require 'wab/shell'
require 'wab/shell_logger'
require 'wab/utils'
require 'wab/uuid'
require 'wab/version'
