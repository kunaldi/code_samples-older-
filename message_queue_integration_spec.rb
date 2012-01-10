spec_dir = File.dirname(__FILE__)
lib_dir = File.join( spec_dir, '../lib/' )
require lib_dir + "message_client/message_client"
require 'fileutils'


describe "MessageQueue" do
  let(:recipients) { [ "mike@mycompany.net", "brian@example.com" ] }
  let(:delivered_email_dir) { File.join( spec_dir, '../cachedMessages' ) }

  before(:all) do
    @mc = MessageClient.new
    @rh = RedisHelper.new
    @resque = ResqueHelper.new
  end

  describe "enqueueing a single message for instant delivery" do

    before(:each) do
      # For this test, we'll send everything to the same destination_id,
      # so that multiple messages are digested.
      @destinations = recipients.map do |recipient|
        { 'id' => `uuidgen`.strip,
          'provider' => 'email',
          'frequency' => 'instantly',
          'address' => recipient,
          'config' => { }
        }
      end
    end

    it "should have destinations with frequency set to instantly" do
      @destinations.each do |destination|
        destination['frequency'].should == 'instantly'
      end
    end

    it "should enqueue and deliver a message to one or more destinations" do
      # Enqueue a generic message for a set of destinations
      # NOTE: For the purposes of testing, we're going to skip actual
      #       queueing... using Resque.inline = true.
      @mc.enqueue(
        { 'id' => `uuidgen`.strip,
          'sender_id' => `uuidgen`.strip,
          'sender_name' => 'test guy'
          'preview' => 'blahblah'
        },
        @destinations
      )

      # Set up expectations before the rspec matcher
      the_expected_number_of_messages = @destinations.count
      # the -2 accounts for the files . and ..
      delivered_email_count = Dir.entries( delivered_email_dir ).size - 2

      # There should be an delivered message for each destination
      delivered_email_count.should eq the_expected_number_of_messages

      # remove the cachedMessages dir with test emails
      FileUtils.rm_rf(delivered_email_dir)
    end

  end

  describe "enqueueing a digest message for delivery hourly or daily" do

    before(:each) do
      # For this test, we'll send everything to the same destination_id,
      # so that multiple messages are digested.
      @fixed_destination_uuid = `uuidgen`.strip
      @destinations = recipients.map do |recipient|
      	{ 'id' => @fixed_destination_uuid,
      	  'provider' => 'email',
      	  'frequency' =>'hourly',
      	  'address' => recipient,
      	  'config' => { }
      	}
      end
    end

    it "should have destinations with frequency set to hourly" do
      @destinations.each do |destination|
        destination['frequency'].should =='hourly'
      end
    end

    it "should have destinations with a common id" do
      @destinations.each do |destination|
        destination['id'].should =~ /#{Regexp.quote(@fixed_destination_uuid)}/
      end
    end

    it "should enqueue and deliver one digest for each destination with multiple messages per digest" do
      3.times do |i|
        # create three unique destinations as we iterate three times
        destination = {
      	  'id' => @fixed_destination_uuid + i.to_s,
      	  'type' => 'email',
      	  'frequency' =>'hourly',
      	  'address' => recipient[0],
      	  'config' => { }
      	}

        # Enqueue 12 different messages for each pair of destinations
        12.times do
        	message = {
        	  'id' => `uuidgen`.strip,
        	  'sender_id' => `uuidgen`.strip,
        	  'sender_name' => 'test guy'
        	  'preview' => 'blahblah'
        	}
        	@mc.enqueue( message, [destination] )
        end
      end

      # Digest destination_ids should be in the redis key messages:hourly.
      redis_destination_ids_list = @rh.pop_digest_destinations_list('hourly')
      redis_destination_ids_list.should have(3).items
      redis_destination_ids_list.should include @fixed_destination_uuid + "0"
      redis_destination_ids_list.should include @fixed_destination_uuid + "1"
      redis_destination_ids_list.should include @fixed_destination_uuid + "2"

      # Messages should be in the redis-keyspace with the destination id
      redis_destination_ids_list.each do |destination_id|
        message_ids = @rh.pop_digest_messages('hourly', destination_id)
        message_ids.should have(12).items

        # Manually enqueue the digests in the same manner as the
        # digest worker (since we're not testing scheduling).
        #
        # Again, since Resque.inline = true, queueing is skipped
        # and the workers are run immediately.
        @resque.enqueue_messages( message_ids, destination_id )
      end

      # Set up expectations before the rspec matcher
      the_expected_number_of_messages = redis_destination_ids_list.count
      # the -2 accounts for the files . and ..
      delivered_email_count = Dir.entries( delivered_email_dir ).size - 2

      # There should be an delivered message for each destination
      delivered_email_count.should eq the_expected_number_of_messages

      # remove the cachedMessages dir with test emails
      FileUtils.rm_rf(delivered_email_dir)
    end

  end

end
