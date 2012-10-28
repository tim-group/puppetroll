describe 'safe_array' do

  def safe_array(array, options)

    cumulative_array = array
    options[:access].each do |element|
      return options[:default_to] unless (cumulative_array.kind_of?(Array)) || (cumulative_array.kind_of?(Hash))

      cumulative_array = cumulative_array[element]
    end

    return cumulative_array
  end


  it 'works on well formed stuff' do
    array = {
        :data=>{
          :resources=>{
            "failed"=>20
    }}}

    safe_array(array, :access=>[:data, :resources,"failed"], :default_to=>0).should eql(20)
  end

  it 'can cope with dodgy messages' do
    array = {
        :data=>{
    }}

    safe_array(array, :access=>[:data, :resources,"failed"], :default_to=>0).should eql(0)
  end
end
