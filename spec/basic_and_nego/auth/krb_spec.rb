require 'spec_helper'
require 'basic_and_nego/auth/krb'

describe BasicAndNego::Auth::Krb do
  let(:logger) { double('logger').as_null_object }
  let(:realm) {'test.realm.com'}
  let(:keytab) {'my keytab'}

  it 'should initialize' do
    krb = BasicAndNego::Auth::Krb.new(logger, realm, keytab)
    expect(krb.realm).to eq(realm)
  end

  it 'should authenticate user/password' do
    user = 'fred'
    passwd = 'passwd'
    k = double('krb5_auth').as_null_object
    allow(k).to receive(:get_init_creds_password).with(user, passwd).and_return(true)
    # k.should_receive(:get_init_creds_password).with(user, passwd).and_return(true)
    # ::Krb5Auth::Krb5.should_receive(:new).and_return(k)
    allow(::Krb5Auth::Krb5).to receive(:new).and_return(k)
    krb = BasicAndNego::Auth::Krb.new(logger, realm, keytab)
    authenticated = krb.authenticate(user, passwd)
    expect(authenticated).to be_a(TrueClass)
    # expect(authenticated).to be_truthy
  end


  it 'should not-authenticate user if kerberos does not agree' do
    user = 'fred'
    passwd = 'passwd'
    k = double('krb5_auth').as_null_object
    allow(k).to receive(:get_init_creds_password).with(user, passwd).and_raise(::Krb5Auth::Krb5::Exception)
    # allow(k).to receive(:get_init_creds_password).with(user, passwd).and_return(true)
    allow(::Krb5Auth::Krb5).to receive(:new).and_return(k)
    krb = BasicAndNego::Auth::Krb.new(logger, realm, keytab)
    authenticated = krb.authenticate(user, passwd)
    expect(authenticated).to be_a(FalseClass)
    # authenticated.should be_false
  end

  it 'should catch exception from underlying system' do
    user = 'fred'
    passwd = 'passwd'
    k = double('krb5_auth').as_null_object
    # k.should_receive(:get_init_creds_password).with(user, passwd).and_raise(::Krb5Auth::Krb5::Exception)
    allow(k).to receive(:get_init_creds_password).with(user, passwd).and_raise(::Krb5Auth::Krb5::Exception)
    allow(::Krb5Auth::Krb5).to receive(:new).and_return(k)
    krb = BasicAndNego::Auth::Krb.new(logger, realm, keytab)
    expect(krb.authenticate(user, passwd)).to be_a(FalseClass)
  end
end
