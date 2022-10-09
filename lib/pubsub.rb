# frozen_string_literal: true

require("google/cloud/pubsub")

class Pubsub
  # @return [Google::Cloud::PubSub::Project]
  def initialize
    @topic_name = "default"
    @subscription_name = "default"
    @client = Google::Cloud::PubSub.new(project_id: "code-challenge")
  end

    # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def find_or_create_topic(topic_name: @topic_name)
    @client.topic(topic_name) || @client.create_topic(topic_name)
  end


  # Find or create a subscription.
  #
  # @param subscription_name and name [String] The name of the subscription to find or create
  # @return [Google::Cloud::PubSub::Subscription]
  def find_or_create_subscription(topic_name: @topic_name, subscription_name: @subscription_name)
    @client.subscription(subscription_name) || find_or_create_topic(topic_name: topic_name)
      .create_subscription(subscription_name)
  end

  # Publish a message to a topic.

  # @param topic_name [String] The name of the topic to publish to
  # @param message [String] The message data to publish
  # @param ordering_key [Integer] The ordering key to use for message ordering

  def publish_message(message:, topic_name: @topic_name, ordering_key: 1)
    topic = find_or_create_topic(topic_name: topic_name)
    topic.enable_message_ordering!
    topic.publish_async(message, ordering_key: ordering_key)
  end
end
