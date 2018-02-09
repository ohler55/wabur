
require 'wab'

module WAB
  module Impl

    # The Sinatra module contains handlers for the Sinatra web server.
    module Sinatra

    end # Sinatra
  end # Impl
end # WAB

require 'wab/impl/sinatra/sender'
require 'wab/impl/sinatra/handler'
require 'wab/impl/sinatra/tql_handler'
require 'wab/impl/sinatra/export_proxy'
require 'wab/impl/sinatra/server'
