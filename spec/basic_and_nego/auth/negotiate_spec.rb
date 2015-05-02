require 'spec_helper'
require 'basic_and_nego/auth/negotiate'
require 'basic_and_nego/nulllogger'
require 'basic_and_nego/request'
require 'base64'

describe BasicAndNego::Auth::Negotiate do

  before(:each) do 
    env = {'HTTP_AUTHORIZATION' => "Negotiate VGhpcyBpcyBteSB0b2tlbg=="}
    @realm = "my realm"
    @keytab = "my keytab"
    @service = "http/hostname"
    @logger = BasicAndNego::NullLogger.new
    @request = BasicAndNego::Request.new(env)
    @gss = double('gss').as_null_object
  end

  it "should try authentication against GSS in case of Negotiate" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    # BasicAndNego::Auth::GSS.should_receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_return("Granted")
    allow(@gss).to receive(:display_name).and_return("fred")
    @a.process
  end

  it "should return 'unauthorized' if authentication fails" do 
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_return(nil)
    @a.process
    expect(@a.response).to_not be_nil
    expect(@a.response[0]).to eq(401)
  end

  it "should return true if authentication worked" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_return("Granted")
    @a.process
    expect(@a.response).to be_nil
  end

  it "should set client's name if authentication worked" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_return("Granted")
    allow(@gss).to receive(:display_name).and_return("fred")
    @a.process
    expect(@a.client_name).to eq("fred")
  end

  it "should set header to returned token if authentication worked" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_return("Granted")
    allow(@gss).to receive(:display_name).and_return("fred")
    @a.process
    expect(@a.client_name).to eq("fred")
    expect(@a.headers['WWW-Authenticate']).to eq("Negotiate #{::Base64.strict_encode64('Granted')}")
  end

  it "should catch GSSAPI exceptions in getting credentials" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_raise(GSSAPI::GssApiError)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    @a.process
    expect(@a.response).to_not be_nil
    expect(@a.response[0]).to eq(500)
  end

  it "should catch GSSAPI exceptions in authenticating token" do
    allow(BasicAndNego::Auth::GSS).to receive(:new).with(@logger, @service, @realm, @keytab).and_return(@gss)
    @a = BasicAndNego::Auth::Negotiate.new(@request, @logger, @realm, @keytab, @service)
    allow(@gss).to receive(:authenticate).and_raise(GSSAPI::GssApiError)
    @a.process
    expect(@a.response).to_not be_nil
    expect(@a.response[0]).to eq(401)
  end

end
