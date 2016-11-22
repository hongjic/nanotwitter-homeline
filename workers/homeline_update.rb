require 'singleton'

class HomeLineUpdate

  include Singleton
  attr_accessor :redis
  
  def initialize 
    @redis = Redis.new
  end

  def exec_task method, params
    instance_eval("#{method} params")
  end

  # user_id = the action user
  # timeline = timeline of the followed user [tweet.create_time, tweet.id]
  def add_follow params
    user_id = params["user_id"]
    timeline = params["timeline"]
    redis_key = "user:#{user_id}:homeline"
    @redis.zadd redis_key, timeline if @redis.exists redis_key
    puts "add_follow:   #{params}"
  end

  # user_id = the action user
  # timeline = timeline of the followed user (wants to delete) [tweet.id]
  def delete_follow params
    user_id = params["user_id"]
    timeline = params["timeline"]
    redis_key = "user:#{user_id}:homeline"
    @redis.zrem "user:#{user_id}:homeline", timeline if @redis.exists redis_key
    puts "delete_follow:   #{params}"
  end

  # follower_list = a list of user id
  # tweet = [tweet.create_time, tweet.id]
  def create_new_tweet params
    userid_list = params["userid_list"]
    tweet = params["tweet"]
    userid_list.each do |user_id|
      redis_key = "user:#{user_id}:homeline"
      @redis.zadd redis_key, tweet[0], tweet[1] if @redis.exists redis_key
    end
    puts "create_new_tweet:   #{params}"
  end

end