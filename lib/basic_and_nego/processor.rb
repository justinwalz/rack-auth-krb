require 'socket'
require 'basic_and_nego/request'
require 'basic_and_nego/auth'

module BasicAndNego
  class Processor
    # DEFAULT_SERVICE = "http@#{Socket::gethostname}"
    DEFAULT_SERVICE = "kerberos.thedemoco.com"

    def initialize(env, logger, realm, keytab, service)
      @env = env
      @logger = logger
      @realm = realm
      @keytab = keytab
      @service = service || DEFAULT_SERVICE

      @request = BasicAndNego::Request.new(@env)
      @authenticator = @request.authenticator.new(@request, @logger, @realm, @keytab, @service)
      @session = @env['rack.session']
    end

    def process_request
      puts "processing request..."
      if authenticated
        puts "Authenticated"
        @logger.debug "User #{@session['REMOTE_USER']} already authenticated"
        @env['REMOTE_USER'] = @session['REMOTE_USER']
      else
        puts "Authenticating..."
        @logger.debug "User not authenticated : delegate to authenticator"

        if authenticate
          puts "authenticated!"
          @env['REMOTE_USER'] = client_name
          @session['REMOTE_USER'] = client_name if @session
        end
      end
    end

    def client_name
      @authenticator.client_name
    end

    def headers
      @authenticator.headers || {}
    end

    def response
      @authenticator.response
    end

    private

    def authenticated
      @session && @session['REMOTE_USER']
    end

    def authenticate
      puts @authenticator.process
      puts "done"
      puts @authenticator.response.nil?
      @authenticator.response.nil?
    end

  end
end
