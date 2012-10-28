require 'puppetroll/namespace'

class PuppetRoll::DependencyRule
  attr_accessor :left
  attr_accessor :right

  def initialize(left,right)
    @left = left
    @right = right
  end
end