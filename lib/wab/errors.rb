
module WAB

  Error      = Class.new(StandardError) # Base for WAB errors and exceptions.
  ParseError = Class.new(Error)         # Raised as a result of a error while parsing.

  class TypeError < Error
    def initialize(msg='Data values must either be a Hash or an Array')
      super(msg)
    end
  end

  class KeyError < Error
    def initialize(msg='Hash keys must be Symbols')
      super(msg)
    end
  end

end # WAB
