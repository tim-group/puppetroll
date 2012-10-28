require 'puppetroll/namespace'
require 'puppetroll/node'
require 'puppetroll/dependency_rule'

class PuppetRoll::Graph
  attr_accessor :nodes
  def initialize(options={:concurrency => 1})
    @nodes = []
    @rules = []
    @concurrency_limit = options[:concurrency]
  end

  def << (node)
    @nodes << node
    return self
  end

  def add_rule(rule)
    (left,right) = rule.split("->")
    @rules << PuppetRoll::DependencyRule.new(left,right)
  end

  def add_hosts(host_list)
    host_list.each {|host|
      @nodes<< PuppetRoll::Node.new(host)
    }
    @nodes.each {|node|
      @rules.each { |rule|
        if node.host =~ /#{rule.left}/
          @nodes.each {|other_node|
            if other_node.host =~ /#{rule.right}/
              node.depends_on(other_node)
            end
          }
        end
      }
    }
  end

  def finished
    @nodes.each{ |node|
      return false if node.state=="queued" || node.state=="running"
    }
    return true
  end

  def exceeds_concurrency_limit?
    @running_nodes = @nodes.reject {|node| node.state != "running"}
    return @running_nodes.size >= @concurrency_limit
  end

  def queued
    queued =  []
    @nodes.each {|node|
      queued << node if node.state=="queued" and node.dependant_nodes().size==0
    }
    return queued
  end

  def running
    running =  []
    @nodes.each {
      |node|
      running << node if node.state=="running"
    }
    return running
  end

  def completed
    completed =  []
    @nodes.each {
      |node|
      completed << node if node.state=="complete"
    }
    return completed
  end

end