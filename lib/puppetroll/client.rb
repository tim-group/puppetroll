require 'puppetroll/namespace'

class PuppetRoll::Client
  def initialize(all_hosts, mc)
    @mc = mc
    @all_hosts = all_hosts
  end

  class ErrorContinuation
    def initialize(&error_block)
      @error_block = error_block
    end

    def otherwise_execute(&block)
      begin
        block.call()
      rescue Exception=>e
        @error_block.call()
        PuppetRoll.log.error(e)
      end
    end
  end

  def on_error(&block)
    return ErrorContinuation.new(&block)
  end

  def validate_not_nil(node, fields)
    part = node
    fields.each do |field|
      raise "malformed message from agent #{node[:sender]}: #{field} is nil" if (part[field] == nil)
      part = part[field]
    end
  end

  def run(host)
    PuppetRoll.log.debug @mc.custom_request("runonce", {:forcerun => true} , host, {"identity" => host})
  end

  def status(host_list = @all_hosts)
    statuses = {}
    @mc.discover :nodes=>host_list
    @mc.status.each do |node|
      on_error {
        statuses[node[:sender]] = "failed"
      }.otherwise_execute {
        validate_not_nil(node, [:data,:status])
        statuses[node[:sender]] = node[:data][:status]
      }
    end
    return statuses
  end

  def last_run_summary(nodes = [])
    @mc.discover :nodes=>nodes
    statuses = {}

    @mc.last_run_summary.each do |node|
      on_error {
        statuses[node[:sender]] = "failed"
      }.otherwise_execute {
        validate_not_nil(node, [:data,:resources,"failed"])
        statuses[node[:sender]] = node[:data][:resources]["failed"] >0?"failed":"passed"
      }
    end
    return statuses
  end
end
