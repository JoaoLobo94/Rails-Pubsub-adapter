# frozen_string_literal: true

namespace(:worker) do
  desc("Run the worker")
  task(run: :environment) do
    # See https://googleapis.dev/ruby/google-cloud-pubsub/latest/index.html

    puts("Worker starting... Listening for messages)")
    # check if there are any arguments passed to the task, otherwise take default values
    if ARGV.count > 1
      Pubsub.new.receive_and_perform_jobs(topic_name: ARGV[1], subscription_name: ARGV[2])
    else
      Pubsub.new.receive_and_perform_jobs
    end
    # Block, letting processing threads continue in the background
    sleep
  end
end
