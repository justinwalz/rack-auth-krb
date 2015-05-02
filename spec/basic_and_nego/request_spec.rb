require 'spec_helper'
require 'basic_and_nego/request'
require 'base64'

describe BasicAndNego::Request do

  it "should be able to detect a no auth" do
    r = BasicAndNego::Request.new({})
    expect(r.authenticator).to eq(BasicAndNego::Auth::None)
  end

  it "should be able to detect a 'basic' scheme" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('fred:pass')}"})
    expect(r.authenticator).to eq(BasicAndNego::Auth::Basic)
  end

  it "should be able to detect a 'negotiate' scheme" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Negotiate #{Base64.encode64('fred:pass')}"})
    expect(r.authenticator).to eq(BasicAndNego::Auth::Negotiate)
  end

  it "should be able to detect an unsupported auth" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Digest #{Base64.encode64('fred:pass')}"})
    expect(r.authenticator).to eq(BasicAndNego::Auth::Unsupported)
  end

  it "should decode credentials" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('fred:pass')}"})
    expect(r.credentials).to eq(["fred", "pass"])
  end

  it "should decode complicated credentials" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Negotiate #{Base64.encode64('justin/admin:Green123$')}"})
    expect(r.credentials).to eq(["justin/admin", "Green123$"])
  end

  it "should return username" do
    r = BasicAndNego::Request.new({'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64('fred:pass')}"})
    expect(r.username).to eq("fred")
  end

end
