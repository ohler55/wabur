module WAB

  # Represents the view in the MVC design pattern. It is primarily used to
  # call the controller with requests but can be used to push data out to a
  # display if push is supported.
  #
  # This class is the default implementation.
  class View

    def initialize()
      # TBD as the default implementation this should be an HTTP server that
      # serves files as well as JSON to a Javascript enabled browser.
    end

    # Push changed data to a display.
    def changed(data)
      # TBD
    end

  end # View
end # WAB
