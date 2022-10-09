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

end
