
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
    background "clouds.jpg"
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
      #@wiimote = para "Wiimote: "
    end
    
    keypress do |k|
      case k
        when :page_up
          robot.throttle_up
        when :page_down
          robot.throttle_down
        when :left
          robot.rudder_right
        when :right
          robot.rudder_left
        when :down
          robot.elevator_up
        when :up
          robot.elevator_down
        when "h"
          robot.hail
        when "s"
          robot.status
        when :tab
          robot.stop
      end
      @info.replace robot.response
    end
    
    every(3) do |count|
      if robot.connected?
        robot.read_compass
        @compass.replace robot.compass_heading
        
        robot.read_battery
        @battery. replace robot.battery_level
      end
    end
                                                
    motion do |x, y|
      if robot.connected?
        left = x
        left = 0 if left < 0
        left = 640 if left > 640
        top = y
        top = 0 if top < 0
        top = 480 if top > 480
        
        if top > 240
          elevator_direction = "d"
          elevator_deflection = ((top/2)/240.0 * 90).to_i
        else
          elevator_direction = "u"
          elevator_deflection = 90 - (top/240.0 * 90).to_i
        end
        
        if left > 320
          rudder_direction = "r"
          rudder_deflection = ((left/2)/320.0 * 90).to_i
          
        else
          rudder_direction = "l"
          rudder_deflection = 90 - (left/320.0 * 90).to_i
          
        end
        
        robot.set_elevator(elevator_direction, elevator_deflection)
        robot.set_rudder(rudder_direction, rudder_deflection)
        #@wiimote.replace "#{top}, #{left}"
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

Mercury.app :title => 'Mercury - flying_robot virtual RC', :width => 640, :height => 480
