
require 'wab'

module WAB
  module Impl

    # The WEBrick module contains handlers for the WEBrick web server.
    module WEBrick

    end # WEBrick
  end # Impl
end # WAB

require 'wab/impl/webrick/export_proxy'
require 'wab/impl/webrick/sender'
require 'wab/impl/webrick/handler'
require 'wab/impl/webrick/tql_handler'
require 'wab/impl/webrick/server'
