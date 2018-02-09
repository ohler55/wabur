
require 'wab'

module WAB
  module Impl

    # The Agoo module contains handlers for the Agoo web server.
    module Agoo

    end # Agoo
  end # Impl
end # WAB

require 'wab/impl/agoo/sender'
require 'wab/impl/agoo/handler'
require 'wab/impl/agoo/tql_handler'
require 'wab/impl/agoo/export_proxy'
require 'wab/impl/agoo/server'
