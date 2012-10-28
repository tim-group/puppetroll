$: << "/opt/puppetroll/lib/"

class MCollective::Application::Puppetroll<MCollective::Application
  description "Rollout puppet changes centrally"
  usage <<-END_OF_USAGE
mco puppetroll [OPTIONS] [FILTERS]

The ACTION can be one of the following:
  
  END_OF_USAGE

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

    engine = PuppetRoll::Engine.new(configuration, [],hosts, PuppetRoll::Client.new(hosts, @mc))
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