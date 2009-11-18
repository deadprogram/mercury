require 'rubygems'
require 'grackle'
require 'serialport' 
require 'lib/flying_robot_proxy'

# twitter stuff
HAPPY_WORDS = ["good", "nice", "love"]
SAD_WORDS = ["bad", "no", "stop", "stay"]

$data = {}

def tweet_hello
  send_tweet("Robot online") if @use_twitter
end

def do_in_child
  read, write = IO.pipe

  pid = fork do
    begin
      read.close
      result = yield
      write.puts [Marshal.dump(result)].pack("m")
    rescue
      result = "waiting..."
    ensure
      exit!(0)
    end
  end

  write.close
  result = read.read
  Process.wait2(pid)
  Marshal.load(result.unpack("m")[0])
rescue
  p "There was an error when Tweeting..."
end

def send_tweet(msg = "Hello")
  $m = msg
  do_in_child do
    client = Grackle::Client.new(:auth=>{:type => :basic, :username => @twitter_username, :password => @twitter_password}, :headers => {'User-Agent' => "Twitterblimp/0.1 Grackle/#{Grackle::VERSION}"})
    client.statuses.update!(:status => $m)
  end
end

def search_recent_tweets_about_flyingrobot
  do_in_child do
    client = Grackle::Client.new
    client[:search].search?(:q => "flyingrobot -from:flyingrobot", :rpp => "4", :since => Date.today.to_s)
  end
end

def search_for_most_recent_dm
  do_in_child do
    client = Grackle::Client.new(:auth=>{:type => :basic, :username => @twitter_username, :password => @twitter_password})
    client.direct_messages? :count => 1
  end
end

# robot logic, as it were
def test_mood(tweets, words)
  count = 0
  tweets.each {|tweet|
    words.each {|w|
      count = count + 1 if tweet.text =~ /\b#{w}\b/
    }
  }
  count
end

def robot_mood?
  @current_mood
end

def check_robot_mood
  return :bored if not @use_twitter
  recent_tweets = search_recent_tweets_about_flyingrobot.results

  happy = test_mood(recent_tweets, HAPPY_WORDS)
  sad = test_mood(recent_tweets, SAD_WORDS)

  if happy > sad
    return :happy 
  elsif sad > happy
    return :sad
  else
    return :bored
  end
end

if ! ARGV[0] || ! ARGV[1]
  puts "Usage ruby twitterblimp.rb /dev/usb.xxx 19200 [joeblow passwrod/--file]"
  exit
end

@current_mood = :bored
@robot = FlyingRobotProxy.new
@robot.connect(ARGV[0], ARGV[1].to_i) # port, baud rate

@robot.hail
puts @robot.response
sleep 1
@robot.hail
puts @robot.response

@robot.status
puts @robot.response

if ARGV[2] && ARGV[3]
  @use_twitter = true
end

if ARGV[2] = "--file"
  @twitter_username = YAML::load_file( File.join(File.dirname(__FILE__), 'config/twitter.yml'))['twitter']['username'] 
  @twitter_password = YAML::load_file( File.join(File.dirname(__FILE__), 'config/twitter.yml'))['twitter']['password']  
else   
  @twitter_username = ARGV[2] 
  @twitter_password = ARGV[3] 
end

tweet_hello

while true do 
  @robot.status
  @r = @robot.response
  p "Tweeting status..."
  send_tweet(@r) if !@r.empty?

  sleep 60
end

# loop looking for tweets that tell us what to do
# while true do  
#   if @notification_count == 0
#     p "Tweeting status..."
#     @robot.status
#     @r = @robot.response
#     @r = "Waiting for status..." if not @r.is_a?(String)
#     send_tweet(@r)
#     @notification_count = 5
#   else
#     @notification_count = @notification_count - 1
#   end
#   
#   p "Checking mood..."
#   new_mood = check_robot_mood
#   if new_mood != robot_mood?
#     puts "I was previously #{robot_mood?}, but now I am #{new_mood}"
#     if new_mood == :happy
#       @robot.set_elevator('c', 0)
#       @robot.set_rudder('l', 90)
#       @robot.set_throttle('f', 40)
#       
#       send_tweet("I was previously #{robot_mood?}, but now I am happy. I will spin for joy.")
#     elsif new_mood == :sad
#       @robot.set_elevator('d', 90)
#       @robot.set_rudder('c', 0)
#       @robot.set_throttle('f', 50)
#       
#       send_tweet("I was previously #{robot_mood?}, but I am now sad. If that is how you feel, I will just crash.")
#     else
#       # bored
#       @robot.set_elevator('c', 0)
#       @robot.set_rudder('c', 0)
#       @robot.set_throttle('f', 0)
#       
#       send_tweet("I was previously #{robot_mood?}, but now I am bored.")
#     end
#     @current_mood = new_mood
#   else
#     send_tweet "I am still #{robot_mood?}."
#   end
#   sleep 30
# end
# 
# 
