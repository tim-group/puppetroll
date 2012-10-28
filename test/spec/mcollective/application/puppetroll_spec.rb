require 'mcollective'
require 'mcollective/application/puppetroll'

describe "PuppetRoll" do

  before {
    mc = @mc = double()
    mc.should_receive(:progress=).with(false)
    mc.should_receive(:disconnect)
    @puppetroll_app =  MCollective::Application::Puppetroll.new
    @puppetroll_app.configuration[:command] = "run"
    @puppetroll_app.configuration[:concurrency] = 1
    singleton = class << @puppetroll_app; self end
    singleton.send :define_method, :rpcclient, lambda {return mc}
  }

  it 'should pass if all puppet runs are a success' do
    @mc.stub(:discover).and_return('host1')
    @mc.stub(:status).and_return([{:sender=>'host1',:data=>{:status=>"stopped"}}])
    @mc.should_receive(:custom_request).with("runonce", {:forcerun=>true}, "host1", {"identity"=>"host1"})
    @mc.stub(:custom_request).with("status", {}, "host1", {"identity"=>"host1"}).and_return([{:data=>{:status=>"stopped"}}])
    @mc.stub(:last_run_summary).and_return([{:data=>{:resources=>{"failed"=>0}}}])
    @puppetroll_app.main()
  end

  it 'should fail if any runs fail' do
    @mc.stub(:discover).and_return('host1')
    @mc.stub(:status).and_return([{:sender=>'host1',:data=>{:status=>"stopped"}}])
    @mc.should_receive(:custom_request).with("runonce", {:forcerun=>true}, "host1", {"identity"=>"host1"})
    @mc.stub(:last_run_summary).and_return([{:sender=>'host1', :data=>{:resources=>{"failed"=>1}}}])
    expect {@puppetroll_app.main()}.to raise_error
  end
end