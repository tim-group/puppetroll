require 'puppetroll'

describe "Graph" do

  it 'returns a list of nodes that have completed their run' do
    node1 = PuppetRoll::Node.new("host1","complete")
    node2 = PuppetRoll::Node.new("host2","complete")
    nodes = PuppetRoll::Graph.new
    nodes << node1 << node2
    nodes.completed.should eql([node1,node2])
  end
  
  it 'only allows nodes that have an indegree of zero to run' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    node1.depends_on(node2)
    nodes = PuppetRoll::Graph.new
    nodes << node1 << node2
    nodes.queued.should eql([node2])
  end

  it 'after a node has become completed, it should allow dependant nodes to be in the queue' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    node1.depends_on(node2)
    nodes = PuppetRoll::Graph.new
    nodes << node1 << node2
    node1.state="complete"
    nodes.queued.should eql([node2])
  end

  it 'allows the graph to be created using hardcoded dependency list' do
    hosts_list = ["node1", "node2"]
    graph = PuppetRoll::Graph.new
    graph.add_rule(".+2->.+1")
    graph.add_hosts(hosts_list)
    graph.nodes.each {|node| node.state="queued"}
    graph.queued.map {|node| node.host}.should eql(["node1"])
  end

  it 'indicates when there are queued or running nodes' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    node1.depends_on(node2)
    nodes = PuppetRoll::Graph.new
    nodes << node1 << node2
    node1.state="running"
    nodes.finished().should eql(false)
  end

  it 'indicates when there are more nodes to process' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    node1.depends_on(node2)
    nodes = PuppetRoll::Graph.new
    nodes << node1 << node2
    node1.state="failed"
    node2.state="complete"
    nodes.finished().should eql(true)
  end

  it 'should run if queue has elements' do
    graph = PuppetRoll::Graph.new
    graph.queued.empty?.should eql(true)
  end

  it 'should run if there are more than allowed_concurrent nodes running' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    graph = PuppetRoll::Graph.new
    node1.state="running"
    graph << node1 << node2
    graph.exceeds_concurrency_limit?.should eql(true)
  end

  it 'should run if there are less than allowed_concurrent nodes running' do
    node1 = PuppetRoll::Node.new("host1","queued")
    node2 = PuppetRoll::Node.new("host2","queued")
    node3 = PuppetRoll::Node.new("host3","queued")
    graph = PuppetRoll::Graph.new(:concurrency=>3)
    node1.state="running"
    node2.state="running"
    graph << node1 << node2 << node3
    graph.exceeds_concurrency_limit?.should eql(false)
  end

  it 'executes dependencies in the correct order' do
    hosts = ["host3","host2","host1"]
    mc_puppet = double()
    rules = []
    rules << ".*host1.*->.*host2.*"
    rules << "host2->host3"
    engine = PuppetRoll::Engine.new({:concurrency=>1},rules,hosts, mc_puppet)
    engine.report
    mc_puppet.stub(:status).and_return({"host3"=>"stopped","host2"=>"stopped","host1"=>"stopped"})
    mc_puppet.stub(:last_run_summary).and_return({"host3"=>nil,"host2"=>nil,"host1"=>nil})
    mc_puppet.should_receive(:run).with("host3").ordered
    mc_puppet.should_receive(:run).with("host2").ordered
    mc_puppet.should_receive(:run).with("host1").ordered
    mc_puppet.stub(:completed?).and_return(true)
    mc_puppet.stub(:failed?).and_return(true)
    engine.execute()
  end
end