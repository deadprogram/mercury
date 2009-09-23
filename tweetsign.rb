require 'rubygems'
require 'usb'
require 'betabrite'
require 'grackle'

def print_tweet(tweet)
  # color the FROM amber
  print BetaBrite::String.new("@" + tweet.from_user).amber
  print " "
  
  if tweet.from_user == "flyingrobot"
    print BetaBrite::String.new(tweet.text).rgb('0000FF')
  else
    print BetaBrite::String.new(tweet.text).yellow
  end
end

def search_5_recent_tweets_from_flyingrobot
  client = Grackle::Client.new
  client[:search].search? :q => "from:flyingrobot", :rpp => "5", :since => Date.today.to_s
end

def clear_sign
  bb = BetaBrite::USB.new { |sign|
    sign.textfile do
      print ""
    end

    sign.textfile('B') do
      print ""
    end

    sign.textfile('C') do
      print ""
    end

    sign.textfile('D') do
      print ""
    end

    sign.textfile('E') do
      print ""
    end
  }.write!
end

def display_recent_tweets
  tweets = search_5_recent_tweets_from_flyingrobot
  p tweets

  bb = BetaBrite::USB.new { |sign|
    sign.textfile do
      print_tweet(tweets.results[0])
    end

    sign.textfile('B') do
      print_tweet(tweets.results[1])
    end

    sign.textfile('C') do
      print_tweet(tweets.results[2])
    end

    sign.textfile('D') do
      print_tweet(tweets.results[3])
    end

    sign.textfile('E') do
      print_tweet(tweets.results[4])
    end
  }.write!
end

# main routine
clear_sign

while true do
  p "Displaying tweets at #{Time.now}"
  display_recent_tweets
  p "Done."
  sleep 60
end





