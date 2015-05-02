require 'spec_helper'
require 'basic_and_nego/auth/basic'
require 'basic_and_nego/nulllogger'
require 'basic_and_nego/request'
require 'base64'

describe BasicAndNego::Auth::Basic do

  before(:each) do 
    env = {'HTTP_AUTHORIZATION' => "Basic #{::Base64.encode64('fred:pass')}"}
    @realm = "my realm"
    @keytab = "my keytab"
    @service = "http/hostname"
    @logger = BasicAndNego::NullLogger.new
    @request = BasicAndNego::Request.new(env)
    # expect(@request).to
    allow(@request).to receive(:credentials).and_return(['fred', 'pass'])
    # @request.should_receive(:credentials).and_return()
    @krb = double('krb5_auth').as_null_object
    allow(BasicAndNego::Auth::Krb).to receive(:new).with(@logger, @realm, @keytab).and_return(@krb)
    # BasicAndNego::Auth::Krb.should_receive(:new).with()
    @a = BasicAndNego::Auth::Basic.new(@request, @logger, @realm, @keytab, @service)
  end

  it "should try authentication against Kerberos in case of Basic" do
    allow(@krb).to receive(:authenticate).with("fred@#{@realm}", "pass").and_return(true)
    # @krb.should_receive(:authenticate).with("fred@#{@realm}", "pass").and_return(true)
    @a.process
    expect(@a.client_name).to eq('fred')
  end

  it "should return 'unauthorized' if authentication fails" do
    allow(@krb).to receive(:authenticate).and_return(false, false)

    # @krb.should_receive(:authenticate).and_return(false, false)
    @a.process
    expect(@a.response).to_not be_nil
    expect(@a.response[0]).to eq(401)
  end

  it "should return true if authentication worked" do
    allow(@krb).to receive(:authenticate).and_return(true)

    # @krb.should_receive(:authenticate).and_return(true)
    @a.process
    expect(@a.response).to be_nil
  end

  it "should set client's name if authentication worked" do
    allow(@krb).to receive(:authenticate).and_return(true)
    @a.process
    expect(@a.client_name).to eq('fred')
  end
  
  it "should try authentication against Kerberos in case of Basic adding automatically the realm" do
    allow(@krb).to receive(:authenticate).and_return(true)
    @a.process
    expect(@a.client_name).to eq('fred')
  end  
 
end

describe "BasicAndNego::Auth::Basic with specific realm" do
  
  before(:each) do 
    env = {'HTTP_AUTHORIZATION' => "Basic #{::Base64.encode64('fred@customRealm:pass')}"}
    @realm = "my realm"
    @keytab = "my keytab"
    @service = "http/hostname"
    @logger = BasicAndNego::NullLogger.new
    @request = BasicAndNego::Request.new(env)
    allow(@request).to receive(:credentials).and_return(['fred@customRealm', 'pass'])

    # @request.should_receive(:credentials).and_return(['fred@customRealm', 'pass'])
    @krb = double('kerberos').as_null_object
    allow(BasicAndNego::Auth::Krb).to receive(:new).with(@logger, @realm, @keytab).and_return(@krb)
    # BasicAndNego::Auth::Krb.should_receive(:new).with(@logger, @realm, @keytab).and_return(@krb)
    @a = BasicAndNego::Auth::Basic.new(@request, @logger, @realm, @keytab, @service)
  end  
  
  it "should try authentication against Kerberos in case of Basic" do
    allow(@krb).to receive(:authenticate).with("fred@customRealm", "pass").and_return(true)
    # @krb.should_receive(:authenticate).with("fred@customRealm", "pass").and_return(true)
    @a.process
    expect(@a.client_name).to eq('fred@customRealm')
  end
    
end
