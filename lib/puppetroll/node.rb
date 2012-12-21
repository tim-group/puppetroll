require 'puppetroll/namespace'

class PuppetRoll::Node
  attr_reader :state
  attr_accessor :host
  attr_reader :time_entered_state

  def initialize(host=nil, state="new")
    @host = host
    @depends_on = []
    @state = state
    @time_entered_state = Time.new()
  end

  def state=(state)
    @state = state
    @time_entered_state = Time.new()
  end

  def been_in_state_for(seconds)
    seconds_in_state = Time.new().to_i-@time_entered_state.to_i
    return seconds_in_state > seconds
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
