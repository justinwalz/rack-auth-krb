require 'spec_helper'
require 'rack/auth/krb/basic_and_nego'
require 'basic_and_nego/stdoutlogger'

class SessionAuthentified
  attr_accessor :app
  def initialize(app,configs = {})
    @app = app
  end

  def call(e)
    e['rack.session'] ||= {}
    e['rack.session']['REMOTE_USER'] = "fred"
    @app.call(e)
  end
end # session

describe "Rack::Auth::Krb::BasicAndNego" do

  before(:each) do
    @basic_app = lambda{|env| [200,{'Content-Type' => 'text/plain'},'OK']}
    @env = env_with_params("/", {}, {'rack.logger' => BasicAndNego::StdOutLogger.new})
  end

  it 'actual integration test' do
    app = setup_rack(@basic_app)

    @env = updated_env_with_params("/", {}, {'rack.logger' => BasicAndNego::StdOutLogger.new})
    # p = ::BasicAndNego::Processor.new
    # allow(p).to receive(:response).twice.and_return(not_authorized_response)
    # allow(p).to receive(:process_request)
    # allow(::BasicAndNego::Processor).to receive(:new).and_return(p)
    first = app.call(@env).first
    # expect(first).to eq(401)

  end

  # it "should return a 401 if authentication failed" do
  #   app = setup_rack(@basic_app)
  #   p = double("processor").as_null_object
  #   allow(p).to receive(:response).twice.and_return(not_authorized_response)
  #   allow(p).to receive(:process_request)
  #   allow(::BasicAndNego::Processor).to receive(:new).and_return(p)
  #   first = app.call(@env).first
  #   expect(first).to eq(401)
  #   # .should == 401
  # end
  #
  # it "should not ask for authentication if client is already authenticated" do
  #   app = setup_rack(@basic_app, {:session => SessionAuthentified})
  #   # app.call(@env).first.should == 200
  #   first = app.call(@env).first
  #   expect(first).to eq(200)
  # end
end
