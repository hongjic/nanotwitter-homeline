require 'redis'
require 'bunny'
require 'byebug'

connection_config = ENV["RABBITMQ_BIGWIG_URL"]
conn = Bunny.new(connection_config)
conn.start

ch = conn.create_channel
q = ch.queue("homeline:update")

redis = Redis.new

begin
  q.subscribe(:block => true) do |delivery_info, properties, body| 
    # body is the string sent by producer.
    puts "something get"
  end
rescue Interrupt => _
  puts "Interrupt "
  conn.close
  exit(0)
end