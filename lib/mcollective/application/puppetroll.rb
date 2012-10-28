$: << "/opt/puppetroll/lib/"

class MCollective::Application::Puppetroll<MCollective::Application
  description "rolls out puppet changes; fails if nodes fail to run puppet; respects ordering dependencies"
  usage "mco puppetroll run <concurrency> -F domain=stag"

  require 'puppetroll'
  require 'puppetroll/client'

  def post_option_parser(configuration)
    if ARGV.length >= 1
      configuration[:command] = ARGV.shift
      configuration[:concurrency] = ARGV.shift.to_i || 1
      raise "I only understand dryrun or run" unless configuration[:command].match /^(dryrun|run)$/
    end
  end

  def main
    @mc = rpcclient("puppetd", :options => options)
    @mc.progress = false
    hosts = @mc.discover

    this_file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
    rules = PuppetRoll.read_rules File.expand_path(File.dirname(this_file) + "/../../../config/default")
    engine = PuppetRoll::Engine.new(configuration, rules,hosts, PuppetRoll::Client.new(hosts, @mc))

    case configuration[:command]
    when "run"
      engine.execute()
    when "dryrun"
      engine.dryrun()
    else
      raise "I only understand run or dryrun"
    end
    @mc.disconnect

    engine.report

    if not engine.successful?
      raise "Puppet Failures: read the output."
    end
  end
end
