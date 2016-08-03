module Grammars
  class Rule
    def initialize(matcher, token)
      @matcher, @token = matcher, "<#{token.to_s.upcase}>"
      unless @matcher.instance_of? Regexp
        @matcher = @matcher.matcher
      end
    end

    attr_reader :matcher, :token
  end
end