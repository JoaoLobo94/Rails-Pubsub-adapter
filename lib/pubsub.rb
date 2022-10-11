# frozen_string_literal: true

require("google/cloud/pubsub")

class Pubsub
  # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def find_or_create_topic(topic_name:)
    client.topic(topic_name) || client.create_topic(topic_name)
  end

  # Find or create a subscription.
  #
  # @param subscription_name and name [String] The name of the subscription to find or create
  # @return [Google::Cloud::PubSub::Subscription]
  def find_or_create_subscription(topic_name:, subscription_name:)
    client.subscription(subscription_name) || find_or_create_topic(topic_name: topic_name)
      .create_subscription(subscription_name)
  end

  # Publish a message to a topic.

  # @param topic_name [String] The name of the topic to publish to
  # @param message [String] The message data to publish
  # @param ordering_key [Integer] The ordering key to use for message ordering

  def publish_message(message:, topic_name:, ordering_key:)
    topic = find_or_create_topic(topic_name: topic_name)
    topic.enable_message_ordering!
    topic.publish(message, ordering_key: ordering_key)
  end

  # Listen for messages on a subscription.
  # @param subscription_name [String] The name of the subscription to listen to
  # @return [Google::Cloud::PubSub::ReceivedMessage]
  def receive_and_perform_jobs(topic_name: "default", subscription_name: "default")
    subscription = find_or_create_subscription(topic_name: topic_name, subscription_name: subscription_name)
    subscription.message_ordering?
    subscriber = subscription.listen do |received_message|
      execute_and_acknowledge_job(received_message)
    end
    at_exit do
      # print exceptions raised by the subscriber thread on exit
      print_exceptions(subscriber)
      subscriber.stop!(10)
    end
    subscriber.start
  end

  private

  # Print exceptions raised by the subscriber thread.
  # @param subscriber [Google::Cloud::PubSub::Subscriber]
  def print_exceptions(subscriber)
    subscriber.on_error do |exception|
      puts("Exception: #{exception.class} #{exception.message}")
    end
  end
  # Print the result of a job.
  # @param received_message [Google::Cloud::PubSub::ReceivedMessage]

  def execute_and_acknowledge_job(message)
    puts("Your calculation result is #{ActiveJob::QueueAdapters::PubsubAdapter::Executor.new(message.data).perform}")
    message.acknowledge!
  end

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new(project_id: "code-challenge")
  end
end
