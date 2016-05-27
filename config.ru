require 'faye'
Faye::WebSocket.load_adapter('thin')

require_relative "vote_hub"

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 300)

vote_hub = VoteHub.new

bayeux.on(:subscribe) do |client_id, channel|
  next if channel.index("sess/").nil?

  event_id = channel.split("sess/").last
  vote_hub.increment!(event_id)
end

bayeux.on(:unsubscribe) do |client_id, channel|
  next if channel.index("sess/").nil?

  event_id = channel.split("sess/").last
  vote_hub.decrement!(event_id)
end

run bayeux
