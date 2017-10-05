# encoding: UTF-8

require 'wab/ui'

class UIController < WAB::UI::MultiFlow

  def initialize(shell)
    super
    
    add_flow(WAB::UI::RestFlow.new(shell,
                                   {
                                     kind: 'Entry',
                                     title: '',
                                     content: "\n\n\n\n",
                                   }, ['title', 'content']))

  end

end # UIController
