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
  # timeline = timeline of the followed user (tweet.id)
  def add_follow params
    user_id = params["user_id"]
    timeline = params["timeline"]
    redis_key = "user:#{user_id}:homeline"
    @redis.sadd redis_key, timeline if @redis.exists redis_key
    puts "add_follow:   #{params}"
  end

  # user_id = the action user
  # timeline = timeline of the followed user (wants to delete) [tweet.id]
  def delete_follow params
    user_id = params["user_id"]
    timeline = params["timeline"]
    redis_key = "user:#{user_id}:homeline"
    @redis.srem "user:#{user_id}:homeline", timeline if @redis.exists redis_key
    puts "delete_follow:   #{params}"
  end

  # follower_list = a list of user id
  # tweet = (tweet json obj)
  def create_new_tweet params
    update_user_homeline params["userid_list"], params["tweet"]["id"]
    update_global_homeline params["tweet"]

    puts "create_new_tweet:   #{params}"
  end

  private 
    def update_user_homeline userid_list, tweetid
      userid_list.each do |user_id|
        redis_key = "user:#{user_id}:homeline"
        @redis.sadd redis_key, tweetid if @redis.exists redis_key
      end
    end

    def update_global_homeline tweet
      global = @redis.get "global:homeline"
      global_tweets = []
      global_tweets = JSON.parse global if global != nil
      global_tweets.unshift tweet
      global_tweets.pop if global_tweets.size > 50
      @redis.set "global:homeline", global_tweets.to_json
    end

end