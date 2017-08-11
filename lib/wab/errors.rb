
module WAB

  # Base for WAB errors and exceptions.
  class Error < StandardError
  end # Error

  # An Exception that is raised as a result of a error while parsing.
  class ParseError < Error
  end # ParseError

end # Oj
