require 'redis'
class VoteHub

  attr_accessor :redis_conn

  def redis
    @redis_conn = Redis.new unless redis_conn
    @redis_conn
  end

  def increment!(event)
    puts "redis: incrementing #{prepare_string(event)}" if ENV["VERBOSE"]
    self.redis.multi do
      self.redis.incr prepare_string(event)
      self.redis.expire prepare_string(event), 5*60*60 # expires counter after 5 hours
    end
    puts " .. is now #{self.redis.get(prepare_string(event))}" if ENV["VERBOSE"]
  end

  def decrement!(event)
    print "redis: decrementing #{prepare_string(event)}" if ENV["VERBOSE"]
    self.redis.decr prepare_string(event)
    puts " .. is now #{self.redis.get(prepare_string(event))}" if ENV["VERBOSE"]
  end

  def set(event, value)
    self.redis.set(prepare_string(event), value.to_i)
  end

  def prepare_string(str)
    "vote_hub/" + (str.gsub(/[^a-zA-Z 0-9]/, "")).gsub(/\s/,'-')
  end

end
