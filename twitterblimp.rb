require 'rubygems'
require 'serialport'
 
require 'grackle'
require 'lib/flying_robot_proxy'

# twitter stuff
def tweet_hello
  send_tweet("Robot online") if @use_twitter
end

def send_tweet(msg = "Hello")
  client = Grackle::Client.new(:auth=>{:type => :basic, :username => TWITTER_USERNAME, :password => TWITTER_PASSWORD})
  client.statuses.update! :status => msg
end

def search_10_recent_tweets_about_flyingrobot
  client = Grackle::Client.new
  client[:search].search? :q => "flyingrobot", :rpp => "10"
end

def search_for_most_recent_dm
  client = Grackle::Client.new(:auth=>{:type => :basic, :username => TWITTER_USERNAME, :password => TWITTER_PASSWORD})
  client.direct_messages? :count => 1
end

# robot logic, as it were
def test_mood(tweets, words)
  count = 0
  tweets.each {|tweet|
    words.each {|w|
      count = count + 1 if tweets.text.match("\b#{w}\b")
    }
  }
  count
end

def robot_mood?
  @current_mood
end

def check_robot_mood
  return :bored if not @use_twitter
  recent_tweets = search_10_recent_tweets_about_flyingrobot.results

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
  puts "Usage ruby twitterblimp.rb /dev/usb.xxx 19200 joeblow passwrod"
  exit
end

robot = FlyingRobotProxy.new
robot.connect(ARGV[0], ARGV[1].to_i) # port, baud rate

if ARGV[2] && ARGV[3]
  @use_twitter = true
end
 
TWITTER_USERNAME = ARGV[2] 
TWITTER_PASSWORD = ARGV[3] 

#tweet_hello
robot.hail
puts robot.response
sleep 1
robot.hail
puts robot.response

robot.status
puts robot.response

# loop looking for tweets that tell us what to do

