# frozen_string_literal: true

require("securerandom")
module ActiveJob
  module QueueAdapters
    class PubsubAdapter
      # Enqueue a job to be performed.
      # @param [ActiveJob::Base] job The job to be performed.

      def enqueue(job)
        Scheduler.new.enqueue(JobWrapper.new(job), queue_name: job.queue_name, ordering_key: job.priority)
      end

      # JobWrapper is a wrapper class for serializing jobs to be sent to pubsub
      # Returns a hash of the job's attributes
      # @return [Hash] The job's attributes
      class JobWrapper
        def initialize(job)
          job.provider_job_id = SecureRandom.uuid
          @job_data = job.serialize
        end
      end

      # Scheduler class is responsible for scheduling and publishing jobs to be performed
      # @param [ActiveJob::Base] job The job to be performed.
      # @param [String] queue_name The name of the queue to publish to
      # @param [String] ordering_key The ordering key to use for message ordering
      class Scheduler
        def initialize
          @pubsub = Pubsub.new
        end

        # Enqueue a job to be performed.
        # subscription name not included, and set to default, for simplicity
        def enqueue(job, queue_name:, ordering_key:)
          @pubsub.find_or_create_subscription(topic_name: queue_name)
          @pubsub.publish_message(topic_name: queue_name, message: job.to_json, ordering_key: ordering_key || 1)
        end
      end

      # Executor class is responsible for deserializing jobs and performing them
      # @param [String] subscription_name The name of the subscription to listen to
      class Executor
        def initialize(message)
          @parsed_message = JSON.parse(message)["job_data"]
        end

        # Perform the job.
        # @return [Object] The result of the job
        def perform
          Base.execute(@parsed_message)
        end
      end
    end
  end
end
