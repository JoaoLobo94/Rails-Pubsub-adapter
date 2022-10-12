# frozen_string_literal: true

require("securerandom")
module ActiveJob
  module QueueAdapters
    class PubsubAdapter
      # Initialize pubsub client
      # @return [Pubsub]
      def initialize
        @pubsub = Pubsub.new
      end

      # Enqueue a job to be performed later.
      # @param job [ActiveJob::Base] The job to be enqueued
      def enqueue(job)
        @pubsub.publish_message(topic_name: job.queue_name,
                                message: JobWrapper.new(job).to_json,
                                ordering_key: job.priority || "1")
      end

      # JobWrapper is a wrapper class for serializing jobs to be sent to pubsub
      # Returns a hash of the job's attributes
      class JobWrapper
        def initialize(job)
          job.provider_job_id = SecureRandom.uuid
          @job_data = job.serialize
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
