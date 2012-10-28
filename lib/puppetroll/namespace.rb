require 'logger'

module PuppetRoll
  def safe_array(array, options)
    cumulative_array = array
    options[:access].each do |element|
      return options[:default_to] unless (cumulative_array.kind_of?(Array)) || (cumulative_array.kind_of?(Hash))
      cumulative_array = cumulative_array[element]
    end
    return cumulative_array
  end

  def read_rules(file)
    IO.read(file).each {|line| rules << line}
  end
  
  def self.log
    return Logger.new(STDOUT)
  end
end