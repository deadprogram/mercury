class FlyingRobot
  attr_reader :throttle_speed, :throttle_direction
  
  def initialize
    @throttle_speed = 0
    @throttle_direction = 'f'
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
  
end



Shoes.setup do
  gem 'toholio-serialport'
  require "serialport"
end

#params for serial port
port_str = "/dev/tty.usbserial-A700636n" # arduino via cable
#port_str = "/dev/tty.usbserial-A6007uob" # xbee explorer
baud_rate = 19200
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
sp.flow_control = SerialPort::SOFT
sp.read_timeout = 50

robot = FlyingRobot.new

Shoes.app :title => 'flying_robot virtual RC', :width => 640, :height => 400 do
  
  @info = para "Throttle: 0"
  
  keypress do |k|
    @key = k.inspect

    if k == :up
      robot.throttle_up
      sp.write "t " + robot.throttle_direction + " " + robot.throttle_speed.to_s + "\r"
      @info.replace sp.read
    elsif k == :down
      robot.throttle_down
      sp.write "t " + robot.throttle_direction + " " + robot.throttle_speed.to_s + "\r"
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


#Shoes.app :title => 'flying_robot virtual RC', :width => 640, :height => 400

