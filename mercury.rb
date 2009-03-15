class FlyingRobot
  attr_reader :throttle_speed, :throttle_direction, :rudder_direction, :rudder_deflection, :elevator_direction, :elevator_deflection
  
  def initialize
    @throttle_speed = 0
    @throttle_direction = 'f'
    @rudder_deflection = 0
    @rudder_direction = 'l'
    @elevator_deflection = 0
    @elevator_direction = 'u'
  end
  
  def throttle_up
    if @throttle_direction == 'f'
      @throttle_speed = @throttle_speed + 1
      if @throttle_speed > 100
        @throttle_speed = 100
      end
    else
      @throttle_speed = @throttle_speed - 1
      if @throttle_speed < 0
        @throttle_direction = 'f'
        @throttle_speed = 1
      end
    end
  end
  
  def throttle_down
    if @throttle_direction == 'f'
      @throttle_speed = @throttle_speed - 1
      if @throttle_speed < 0
        @throttle_speed = 1
        @throttle_direction = 'r'
      end
    else
      @throttle_speed = @throttle_speed + 1
      if @throttle_speed > 100
        @throttle_speed = 100
      end
    end
  end
  
  def rudder_left
    if @rudder_direction == 'l'
      @rudder_deflection = @rudder_deflection + 1
      if @rudder_deflection > 90
        @rudder_deflection = 90
      end
    else
      @rudder_deflection = @rudder_deflection - 1
      if @rudder_deflection < 0
        @rudder_direction = 'l'
        @rudder_deflection = 1
      end
    end
  end

  def rudder_right
    if @rudder_direction == 'r'
      @rudder_deflection = @rudder_deflection + 1
      if @rudder_deflection > 90
        @rudder_deflection = 90
      end
    else
      @rudder_deflection = @rudder_deflection - 1
      if @rudder_deflection < 0
        @rudder_direction = 'r'
        @rudder_deflection = 1
      end
    end
  end
  
  def elevator_up
    if @elevator_direction == 'u'
      @elevator_deflection = @elevator_deflection + 1
      if @elevator_deflection > 90
        @elevator_deflection = 90
      end
    else
      @elevator_deflection = @elevator_deflection - 1
      if @elevator_deflection < 0
        @elevator_direction = 'u'
        @elevator_deflection = 1
      end
    end
  end

  def elevator_down
    if @elevator_direction == 'd'
      @elevator_deflection = @elevator_deflection + 1
      if @elevator_deflection > 90
        @elevator_deflection = 90
      end
    else
      @elevator_deflection = @elevator_deflection - 1
      if @elevator_deflection < 0
        @elevator_direction = 'd'
        @elevator_deflection = 1
      end
    end
  end
  
end



Shoes.setup do
  gem 'toholio-serialport'
  require "serialport"
end

#params for serial port
#@port_str = "/dev/tty.usbserial-A8007UEt"
port_str = "/dev/tty.usbserial-A700636n" # arduino via cable 
#@port_str = "/dev/tty.usbserial-A6007uob" # xbee explorer
baud_rate = 19200
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

SP = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
SP.flow_control = SerialPort::SOFT
SP.read_timeout = 50

FLYING_ROBOT = FlyingRobot.new

class Mercury < Shoes
  
  url "/", :index
  
  def sp
    SP
  end
  
  def robot
    FLYING_ROBOT
  end
  
  def index
    stack do
      para "Mercury"
    end
    stack do 
      @info = para "Starting flying_robot..."
    end
    
    keypress do |k|
      @key = k.inspect

      if k == :page_up
        robot.throttle_up
        sp.write "t " + robot.throttle_direction + " " + robot.throttle_speed.to_s + "\r"
        @info.replace sp.read
      elsif k == :page_down
        robot.throttle_down
        sp.write "t " + robot.throttle_direction + " " + robot.throttle_speed.to_s + "\r"
        @info.replace sp.read
      elsif k == :right
        robot.rudder_right
        sp.write "r " + robot.rudder_direction + " " + robot.rudder_deflection.to_s + "\r"
        @info.replace sp.read
      elsif k == :left
        robot.rudder_left
        sp.write "r " + robot.rudder_direction + " " + robot.rudder_deflection.to_s + "\r"
        @info.replace sp.read
      elsif k == :up
        robot.elevator_up
        sp.write "e " + robot.elevator_direction + " " + robot.elevator_deflection.to_s + "\r"
        @info.replace sp.read
      elsif k == :down
        robot.elevator_down
        sp.write "e " + robot.elevator_direction + " " + robot.elevator_deflection.to_s + "\r"
        @info.replace sp.read
      elsif k == "h"
        sp.write "h\r"
        @info.replace sp.read
      elsif k == "s"
        sp.write "s\r"
        @info.replace sp.read
      else
        @info.replace k
      end
    end
    
  end

  
end

Mercury.app :title => 'Mercury - flying_robot virtual RC', :width => 640, :height => 400
