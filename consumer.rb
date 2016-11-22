require 'redis'
require 'bunny'
require 'json'
require './workers/homeline_update'

require 'byebug'

connection_config = ENV["RABBITMQ_BIGWIG_URL"]
conn = Bunny.new(connection_config)
conn.start

ch = conn.create_channel
q = ch.queue("homeline:update")
homeline_update = HomeLineUpdate.instance

begin
  q.subscribe(:block => true) do |delivery_info, properties, body| 
    # body is the string sent by producer.
    request = JSON.parse body
    method = request["method"]
    params = request["params"]
    homeline_update.exec_task(method, params)
  end
rescue Interrupt => _
  puts "Interrupt "
  conn.close
  exit(0)
end