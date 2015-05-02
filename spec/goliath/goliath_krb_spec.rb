require 'spec_helper'
require 'goliath/rack/auth/krb/basic_and_nego'

describe Goliath::Rack::Auth::Krb::BasicAndNego do
  it 'accepts an app' do
    expect { Goliath::Rack::Auth::Krb::BasicAndNego.new('my app', 'my realm', 'my keytab') }.to_not raise_error
    # lambda { Goliath::Rack::Auth::Krb::BasicAndNego.new('my app', 'my realm', 'my keytab') }.should_not raise_error
  end

  describe 'with middleware' do
    before(:each) do
      @app = double('app').as_null_object
      @env = Goliath::Env.new
      @env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded; charset=utf-8'
      @auth = Goliath::Rack::Auth::Krb::BasicAndNego.new(@app, 'my realm', 'my keytab')
    end


    it 'returns status, headers and body from the app' do
      app_headers = {'Content-Type' => 'hash'}
      app_body = {:a => 1, :b => 2}
      p = double("processor").as_null_object
      allow(p).to receive(:response).and_return(nil)
      # p.should_receive(:response).and_return(nil)
      add_headers = {"fred" => "foo"}
      allow(p).to receive(:headers).and_return(add_headers)
      allow(::BasicAndNego::Processor).to receive(:new).and_return(p)
      allow(p).to receive(:process_request)
      allow(@app).to receive(:call).and_return([200, app_headers, app_body])

      status, headers, body = @auth.call(@env)
      expect(status).to eq(200)
      # status.should == 200
      expect(headers['fred']).to eq('foo')
      # headers['fred'].should == "foo"
      # body.should == app_body
      expect(body).to eq(app_body)
    end

    it "returns error in case of failing authentication" do
      app_headers = {'Content-Type' => 'hash'}
      app_body = {:a => 1, :b => 2}
      p = double("processor").as_null_object
      r = [401, {}, "foo"]
      allow(p).to receive(:response).twice.and_return(r)
      allow(p).to receive(:process_request)
      # .should_receive(:new).and_return(p)
      allow(::BasicAndNego::Processor).to receive(:new).and_return(p)
      response = @auth.call(@env)
      expect(response).to eq(r)
      # response.should =~ r
    end
  end
end
