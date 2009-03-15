
Shoes.setup do
  gem 'toholio-serialport'
  require "serialport"
end

require 'lib/flying_robot_proxy'

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

FLYING_ROBOT = FlyingRobotProxy.new(SP)

class Mercury < Shoes
  
  url "/", :index
  url "/settings", :settings
  
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
      para "Controls"
      
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

  
end

Mercury.app :title => 'Mercury - flying_robot virtual RC', :width => 640, :height => 400
