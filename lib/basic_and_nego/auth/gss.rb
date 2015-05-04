require 'gssapi'

module BasicAndNego
  module Auth
    class GSS
      attr_reader :gssapi, :logger

      #
      # Can raise GSSAPI::GssApiError
      #
      def initialize(logger, service, realm, keytab)
        @logger = logger
        @service = service

        @realm = realm
        @keytab = keytab
        @logger.debug "creating GSSAPI wih @realm = #{@realm.inspect}, @service = #{@service.inspect}, @keytab = #{@keytab.inspect}"
        @gssapi = GSSAPI::Simple.new(@realm, @service, @keytab)
        # @gssapi = GSSAPI::Simple.new(@realm, nil, nil)

        gssapi.acquire_credentials
      end

      #
      #  Attempt to authenticate the furnished token against gssapi
      #
      # It return nil (in case of error) or the token sent back
      # by the gssapi if the authentication is successfull
      #
      def authenticate(token)
        @logger.debug "Accepting context with token #{token} [GSS]"
        return gssapi.accept_context(token)
      end

      def display_name
        @logger.debug "Getting display name [GSS]"
        return gssapi.display_name
      end
    end
  end
end
