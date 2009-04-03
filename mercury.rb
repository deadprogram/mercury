
Shoes.setup do
  gem 'toholio-serialport'
end

require "serialport"
require 'lib/flying_robot_proxy'

FLYING_ROBOT = FlyingRobotProxy.new

class Mercury < Shoes
  @session = {}
  class << self
    attr_reader :session
  end

  def session
    Mercury.session
  end
  
  
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
      stack { @info = para "Starting flying_robot..." }
      @battery = para "Battery voltage: ---" 
      @compass = para "Compass heading: ---" 
      @compass_display = flow { draw_background }
      flow { @battery_display = progress }
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
        when "a"
          robot.toggle_autopilot
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
        @battery.replace robot.battery_level
      end
      @compass_display.clear do
        draw_background
        draw_compass_hand
      end
      @battery_power = @battery.text[15, @battery.text.length].to_f
      @battery_display.fraction = ( @battery_power - 6250) / 2000.0
    end
    
    
                                                
    # motion do |x, y|
    #   if robot.connected? && session[:use_mouse]
    #     left = x
    #     left = 0 if left < 0
    #     left = 640 if left > 640
    #     top = y
    #     top = 0 if top < 0
    #     top = 480 if top > 480
    #     
    #     if top > 240
    #       elevator_direction = "d"
    #       elevator_deflection = ((top/2)/240.0 * 90).to_i
    #     else
    #       elevator_direction = "u"
    #       elevator_deflection = 90 - (top/240.0 * 90).to_i
    #     end
    #     
    #     if left > 320
    #       rudder_direction = "r"
    #       rudder_deflection = ((left/2)/320.0 * 90).to_i
    #       
    #     else
    #       rudder_direction = "l"
    #       rudder_deflection = 90 - (left/320.0 * 90).to_i
    #       
    #     end
    #     
    #     robot.set_elevator(elevator_direction, elevator_deflection)
    #     robot.set_rudder(rudder_direction, rudder_deflection)
    #     #@wiimote.replace "#{top}, #{left}"
    #   end
    # end
  end

  def draw_background
    @centerx, @centery = 126, 140
    background rgb(230, 240, 200)

    fill white
    stroke black
    strokewidth 4
    oval @centerx - 102, @centery - 102, 204, 204

    fill black
    nostroke
    oval @centerx - 5, @centery - 5, 10, 10

    stroke black
    strokewidth 1
    line(@centerx, @centery - 102, @centerx, @centery - 95)
    line(@centerx - 102, @centery, @centerx - 95, @centery)
    line(@centerx + 95, @centery, @centerx + 102, @centery)
    line(@centerx, @centery + 95, @centerx, @centery + 102)
  end

  def draw_compass_hand
    @centerx, @centery = 126, 140
    @current_reading = @compass.text[17, @compass.text.length].to_f
    _x = 90 * Math.sin( @current_reading * Math::PI / 360 )
    _y = 90 * Math.cos( @current_reading * Math::PI / 360 )
    stroke black
    strokewidth 6
    line(@centerx, @centery, @centerx + _x, @centery - _y)
  end

  def connect
    stack do
      banner "Mercury"
    end
    stack do
      para "Port"
      @port = edit_line("/dev/tty.usbserial-A700636n", :width => 200)
      flow { @use_mouse = check; para "Use Mouse/Wiimote Cnotrol" }
      
      button("Connect") {
        session[:use_mouse] = @use_mouse.checked?
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
