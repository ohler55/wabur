#!/usr/bin/env ruby
# encoding: UTF-8

require 'wab'
require 'wab/ui'

class UIController < WAB::UI::RestFlow

  def initialize(shell)
    super(shell, {
            kind: 'Entry',
            title: '',
            content: "\n\n\n\n",
          }, [:title, :content])
  end

end # UIController
