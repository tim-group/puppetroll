require 'puppetroll/graph'

class PuppetRoll::Engine
  attr_accessor :graph
  def initialize(config, rules, hosts, mc_puppet)
    @graph = PuppetRoll::Graph.new(config)
    rules.each do |rule|
      @graph.add_rule(rule)
    end
    @graph.add_hosts(hosts)
    @mc_puppet = mc_puppet
  end

  def update_status(statuses)
    raise "statuses cannot be nil" if statuses == nil
    @graph.nodes.each do |node|
      status = statuses[node.host]
      if (node.state == "new" and status != "stopped")
        PuppetRoll.log.info("cannot run puppet on #{node.host} because it's status is: #{status}\n")
        node.state = "failed"
      end

      if (node.state =="new" and status == "stopped")
        PuppetRoll.log.info("progressing #{node.host} from new->queued\n")
        node.state = "queued"
      end

      if (node.state == "running" and status == "stopped")
        PuppetRoll.log.info("progressing #{node.host} from running->complete\n")
        node.state = "complete"
      end

      if (node.state == "complete" and status == "failed")
        PuppetRoll.log.info("progressing #{node.host} from complete->failed\n")
        node.state = "failed"
      end

      if (node.state == "complete" and status == "passed")
        PuppetRoll.log.info("progressing #{node.host} from complete->passed\n")
        node.state = "passed"
      end
    end
  end

  def execute()
    update_status(@mc_puppet.status)
    while(not @graph.finished())
      while !@graph.queued.empty? and  !@graph.exceeds_concurrency_limit?
        node = @graph.queued.first
        @mc_puppet.run(node.host)
        node.state = "running"
        print "#{Time.now} #{node.host} running puppet\n"
      end

      running_hosts = @graph.running.map do |node| node.host end
      update_status(@mc_puppet.status(running_hosts)) if running_hosts.size>0
      completed_hosts = @graph.completed.map do |node| node.host end
      update_status(@mc_puppet.last_run_summary(completed_hosts)) if completed_hosts.size>0
    end
  end

  def report
    counts = {}
    print "\n\n****\n\n"
    @graph.nodes.each {|node|
      print "#{node.host} [#{node.state}] https://foreman.youdevise.com/hosts/#{node.host}/reports/last\n"
      if (counts[node.state]==nil)
        counts[node.state]=1
      else
        counts[node.state]+=1
      end
    }
    counts.each do |state, count|
      print "#{state} => #{count} \n"
    end
  end

  def successful?
    @graph.nodes.each {|node|
      return false if node.state=="failed"
    }
    return true
  end
end
