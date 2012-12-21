require 'puppetroll'

describe PuppetRoll::Engine do

  it 'transitions new->queued when puppetd is stopped' do
    rules = []
    hosts = ["host1"]
    mc_puppet = double
    engine = PuppetRoll::Engine.new({},rules,hosts,mc_puppet)
    engine.update_status({"host1"=>"stopped"})
    engine.graph.nodes[0].state.should eql("queued")
  end

  it 'transitions new->queued when puppetd is failed' do
    rules = []
    hosts = ["host1"]
    mc_puppet = double
    engine = PuppetRoll::Engine.new({},rules,hosts,mc_puppet)
    engine.update_status({"host1"=>"failed"})
    engine.graph.nodes[0].state.should eql("queued")
  end


  it 'transitions nodes that did not return status info->failed' do
    rules = []
    hosts = ["host1"]
    mc_puppet = double
    engine = PuppetRoll::Engine.new({},rules,hosts,mc_puppet)
    engine.update_status({  })
    engine.graph.nodes[0].state.should eql("failed")
  end
end
