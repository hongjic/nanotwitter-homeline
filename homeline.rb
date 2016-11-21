require 'redis'
require 'bunny'

conn = Bunny.new
conn.start

ch = conn.create_channel
q = ch.queue("hello")

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] Received #{body}"
    # imitate some work
    sleep body.count(".").to_i
    puts " [x] Done"
  end
rescue Interrupt => _
  puts "Interrupt "
  conn.close
  exit(0)
end