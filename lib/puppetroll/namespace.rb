require 'logger'

module PuppetRoll
  def self.read_rules(file)
    rules = []
    IO.read(file).each {|line| rules << line}
    return rules
  end
  
  def self.log
    return Logger.new(STDOUT)
  end
end