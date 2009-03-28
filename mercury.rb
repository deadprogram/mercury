
Shoes.setup do
  gem 'toholio-serialport'
  require "serialport"
end

require 'lib/flying_robot_proxy'

FLYING_ROBOT = FlyingRobotProxy.new

class Mercury < Shoes
  
  url "/", :index
  url "/fly", :fly
  url "/connect", :connect
  
  def index
    stack do
      banner "Mercury"
    end
    stack do
      button("Connect") {visit "/connect"}
    end
  end
  
  def fly
    stack do
      banner "Mercury"
    end
    stack do
      @battery = para "Battery voltage: ---" 
      @compass = para "Compass heading: ---" 
      @info = para "Starting flying_robot..."
    end
    
    keypress do |k|
      case k
        when :page_up
          robot.throttle_up
          @info.replace robot.response
        when :page_down
          robot.throttle_down
          @info.replace robot.response
        when :right
          robot.rudder_right
          @info.replace robot.response
        when :left
          robot.rudder_left
          @info.replace robot.response
        when :up
          robot.elevator_up
          @info.replace robot.response
        when :down
          robot.elevator_down
          @info.replace robot.response
        when "h"
          robot.hail
          @info.replace robot.response
        when "s"
          robot.status
          @info.replace robot.response
      end
    end
    
    every(3) do |count|
      if robot.connected?
        robot.read_compass
        @compass.replace robot.compass_heading
        
        robot.read_battery
        @battery.replace robot.battery_level
      end
    end
  end

  def connect
    stack do
      banner "Mercury"
    end
    stack do
      para "Port"
      @port = edit_line("/dev/tty.usbserial-A700636n", :width => 200)
      
      button("Connect") {
        robot.connect(@port.text)
        visit "/fly"
      }
    end
    
  end
  
  def robot
    FLYING_ROBOT
  end
end

Mercury.app :title => 'Mercury - flying_robot virtual RC', :width => 640, :height => 400
