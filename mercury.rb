
Shoes.setup do
  gem 'toholio-serialport'
  require "serialport"
end

require 'lib/flying_robot_proxy'

FLYING_ROBOT = FlyingRobotProxy.new

class Mercury < Shoes
  
  url "/", :index
  url "/settings", :settings
  
  def sp
    FLYING_ROBOT.sp
  end
  
  def robot
    FLYING_ROBOT
  end
  
  def index
    stack do
      banner "Mercury"
    end
    stack do
      button("Settings") {visit "/settings"}
    end
    stack do 
      @info = para "Starting flying_robot..."
    end
    
    keypress do |k|
      @key = k.inspect

      if k == :page_up
        robot.throttle_up
        @info.replace sp.read
      elsif k == :page_down
        robot.throttle_down
        @info.replace sp.read
      elsif k == :right
        robot.rudder_right
        @info.replace sp.read
      elsif k == :left
        robot.rudder_left
        @info.replace sp.read
      elsif k == :up
        robot.elevator_up
        @info.replace sp.read
      elsif k == :down
        robot.elevator_down
        @info.replace sp.read
      elsif k == "h"
        robot.hail
        @info.replace sp.read
      elsif k == "s"
        robot.status
        @info.replace sp.read
      else
        @info.replace k
      end
    end
    
  end

  def settings
    stack do
      banner "Mercury"
    end
    stack do
      para "Port"
      @port = edit_line(:width => 200)
      
      button("Save") {
        robot.connect(@port.text)
        visit "/"
      }
    end
    
  end
end

Mercury.app :title => 'Mercury - flying_robot virtual RC', :width => 640, :height => 400
