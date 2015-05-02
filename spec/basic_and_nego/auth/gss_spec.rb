require 'spec_helper'
require 'basic_and_nego/auth/gss'

describe BasicAndNego::Auth::GSS do
  let(:realm) { "my realm"}
  let(:service) { "foo" }
  let(:keytab) { "my keytab" }
  let(:gssapi) { double("gss api").as_null_object }
  let(:logger) { double('logger').as_null_object }
  let(:good_request) { BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Negotiate VGhpcyBpcyBteSB0b2tlbg=="})}

  it "should initialize and deal with gssapi" do
    allow(gssapi).to receive(:acquire_credentials)
    # gssapi.should_receive(:acquire_credentials)
    allow(GSSAPI::Simple).to receive(:new).with(realm, service, keytab).and_return(gssapi)
    # GSSAPI::Simple.should_receive(:new).with(realm, service, keytab).and_return(gssapi)
    g = BasicAndNego::Auth::GSS.new(logger, service, realm, keytab)
  end

  it "should authenticate request" do
    allow(gssapi).to receive(:acquire_credentials)
    allow(gssapi).to receive(:accept_context).and_return("Granted")

    # gssapi.should_receive(:acquire_credentials)
    # gssapi.should_receive(:accept_context).and_return("Granted")
    allow(GSSAPI::Simple).to receive(:new).with(realm, service, keytab).and_return(gssapi)

    # GSSAPI::Simple.should_receive(:new).with(realm, service, keytab).and_return(gssapi)
    g = BasicAndNego::Auth::GSS.new(logger, service, realm, keytab)
    result = g.authenticate("My token")
    expect(result).to eq('Granted')
    # g.authenticate("My token").should == ""
  end

end
