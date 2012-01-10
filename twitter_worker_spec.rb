spec_dir = File.dirname(__FILE__)
lib_dir = File.join( spec_dir, '../lib/' )
#require spec_dir + '/spec_helper'
require lib_dir + 'workers/twitter_worker'

describe Worker::TwitterWorker do
  let(:twitter_worker) { Worker::TwitterWorker.new }
  let(:recipients) { [ "gharrison", "jsmith", "bgates", "" ] }
  
  before(:all) do
    @destinations = recipients.map do |recipient|
      { 'id' => `uuidgen`.strip,
        'provider' => 'twitter',
        'frequency' => 'instantly',
        'address' => recipient,
        'config' => { }
      }
    end
  end   
  
  describe "instant message delivery to Twitter destinations" do
    before(:each) do
      @valid_messages = [{
        'id' => `uuidgen`.strip,
        'sender_id' => `uuidgen`.strip,
        'sender_name' => 'CM Twitter Test',
        'preview' => (0...20).collect{rand(36).to_s(36)}.map{|x| (rand<0.5)?x:x.upcase}.join,
        'remaining' => 1,
      }]
      
      @invalid_messages = [{
        'id' => `uuidgen`.strip,
        'sender_id' => `uuidgen`.strip,
        'sender_name' => 'CM Twitter Test',
        'preview' => (0...141).collect{rand(36).to_s(36)}.map{|x| (rand<0.5)?x:x.upcase}.join,
        'remaining' => 1,
      }]
      
    end
    
    it "should have destinations with frequency set to instantly" do
      @destinations.each do |destination|
        destination['frequency'].should == 'instantly'
      end
    end
  
    it "raises 404 Twitter::NotFound if user does not exist" do
      expect do
        twitter_worker.deliver(@valid_messages, @destinations[3]) #invalid user
      end.to raise_error(Twitter::NotFound)
    end
  
    #K: This could be any unaccapted request
    it "raises 400 Twitter::BadRequest if request is not valid" do
      destination = {
          'id' => `uuidgen`.strip,
          'provider' => 'twitter',
          'frequency' => 'instantly',
          :address => 'bgreg',
          'config' => { }
      }
      
      expect do
        twitter_worker.deliver(@valid_messages, destination)
      end.to raise_error(Twitter::BadRequest)
    end
    
    it "raises 403 Twitter::Forbidden if message is longer than 140 chars)" do
      expect do
        twitter_worker.deliver(@invalid_messages, @destinations[0]) # follower
      end.to raise_error(Twitter::Forbidden)
    end
    
    it "raises Twitter::Forbidden if recipient is not a follower" do
      expect do
        twitter_worker.deliver(@valid_messages, @destinations[1]) # non follower
      end.to raise_error(Twitter::Forbidden)
    end
    
    #K: TODO: Write a test for return 200: OK
  
    # Add more tests here if required
  
  end
end