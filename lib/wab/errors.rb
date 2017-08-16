
module WAB

  # Base for WAB errors and exceptions.
  Error = Class.new(StandardError)

  # An Exception that is raised as a result of a error while parsing.
  ParseError = Class.new(Error)

end # WAB
