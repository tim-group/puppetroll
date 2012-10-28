require 'puppetroll'

describe PuppetRoll::Client do

  before do
    @mc = double()
    @mc.should_receive(:discover)
  end

  it 'gets the status from the puppetd agents on the discovered boxes' do
    @mc.stub(:status).and_return([
      {
      :sender=>'host1',
      :data=>{:status=>"stopped"}
      },
      {
      :sender=>'host2',
      :data=>{:status=>"stopped"}
      }])
    client = PuppetRoll::Client.new([],@mc)
    client.status().should eql({"host1"=>"stopped", "host2"=>"stopped"})
  end

  it 'reports when specific clients give erroneous results' do
    @mc.stub(:status).and_return([
      {
      :sender=>'host1',
      :data=>nil
      },
      {
      :sender=>'host2',
      :data=>{:status=>"stopped"}
      }])
    client = PuppetRoll::Client.new([],@mc)
    client.status().should eql({"host1"=>"failed", "host2"=>"stopped"})
  end

end