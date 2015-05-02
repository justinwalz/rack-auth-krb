require "krb5_auth"

module BasicAndNego
  module Auth
    class Krb
      attr_reader :realm, :keytab, :logger

      def initialize(logger, realm, keytab)
        @logger = logger
        @realm = realm
        @keytab = keytab
      end

      def authenticate(user, passwd)
        successfull = false

        @krb5 = ::Krb5Auth::Krb5.new
        begin
          @krb5.get_init_creds_password(user, passwd)
          successfull = true
        rescue ::Krb5Auth::Krb5::Exception => e
          logger.error "Failed to authenticate user '#{user}': #{e.message}"
        end

        # Kerberos::Krb5.new do |krb5|
        #   begin
        #     krb5.get_init_creds_password(user, passwd)
        #     successfull = true
        #   rescue Kerberos::Krb5::Exception => e
        #     logger.error "Failed to authenticate user '#{user}': #{e.message}"
        #   end
        # end
        successfull
      end
    end
  end
end
