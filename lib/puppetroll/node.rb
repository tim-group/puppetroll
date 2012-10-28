require 'puppetroll/namespace'

class PuppetRoll::Node
  attr_accessor :state
  attr_accessor :host
  def initialize(host=nil, state="new")
    @host = host
    @depends_on = []
    @state = state
  end

  def dependencies
    return @depends_on
  end

  def dependant_nodes()
    return @depends_on.reject do |node|
      node.state == "complete" || node.state == "failed"
    end
  end

  def depends_on(other_node)
    @depends_on << other_node
  end
end