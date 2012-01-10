require 'active_support'
libdir = File.dirname(__FILE__) + '/../'
require libdir + 'helpers/mongo_helper'

module Worker
  class DeliveryWorker

    @queue = :messages_delivery

    def self.perform(*args)
      message_ids, destination_id = args

      # Use MongoHelper to get the messages and destination for delivery
      @mongo = MongoHelper.new()
      messages, destination = @mongo.get_messages_and_destination(message_ids, destination_id)

      # Instantiate a new worker object for a given destination type.
      # We'll use this to actually perform the delivery (via the deliver method).
      worker = self.new_worker_for(destination['provider'])

      worker.deliver(messages, destination)
      @mongo.decrement_remaining_and_delete_delivered(message_ids, destination_id)
    end

  private

    def self.new_worker_for(destination_type)
      require self.worker_file_for(destination_type)
      self.worker_class_for(destination_type).new
    end

    def self.worker_file_for(destination_type)
      "#{File.dirname(__FILE__)}/#{destination_type}_worker"
    end

    def self.worker_class_for(destination_type)
      ActiveSupport::Inflector.constantize("Worker::#{destination_type.capitalize}Worker")
    end

  end
end

