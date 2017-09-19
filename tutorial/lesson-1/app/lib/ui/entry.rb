# encoding: UTF-8

require 'wab/ui'

class Entry < WAB::UI::RestFlow

  def initialize()
    template = {
      kind: 'Entry',
      title: '',
      content: "\n\n\n\n",
    }
    super(template)
  end

end # Entry
