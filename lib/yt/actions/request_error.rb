module Yt
  # Custom Exception class stores a Hash in the message, whose values can
  # be accessed with custom methods like .code
  class RequestError < StandardError
    def code
      
    end
    
  private
  
    def request_error
      # If the error was raised with a Hash, e.g. raise RequestError, code: 404, body: 'Not Found'
      eval(message)
    end
  end
end

    def reasons
      error.fetch('errors', []).map{|e| e['reason']}
    end

    def error
      eval(message)['error'] rescue {}
    end

    def oauth_url
      eval(message)['oauth_url']
    end
  end
end