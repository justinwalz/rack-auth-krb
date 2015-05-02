require 'rack/auth/abstract/request'
module BasicAndNego
  class Request < Rack::Auth::AbstractRequest
    attr_reader :credentials

    def authenticator
      # return BasicAndNego::Auth::Negotiate
      # return BasicAndNego::Auth::Negotiate


      if !provided?
        puts "provided? #{provided?}"
        puts "NONE"
        BasicAndNego::Auth::None
      elsif supported_auth?
        puts "supported_auth?? #{supported_auth?}"
        puts "CONST: #{scheme.to_s.capitalize}"
        BasicAndNego::Auth.const_get(scheme.to_s.capitalize)
      else
        puts "UNSUPPORTED"
        BasicAndNego::Auth::Unsupported
      end
    end

    def credentials
      @credentials ||= params.unpack("m*").first.split(/:/, 2)
    end

    def username
      credentials.first
    end 

    private

    def supported_auth?
      %w(basic negotiate).include? scheme.to_s
    end
  end
end
