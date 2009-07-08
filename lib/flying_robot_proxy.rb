class FlyingRobotProxy
  attr_reader :throttle_speed, :throttle_direction, :rudder_direction, :rudder_deflection, :elevator_direction, :elevator_deflection,
              :sp, :compass_heading, :battery_level
  
  def initialize
    @rudder_increment = 45
    @elevator_increment = 23
    @throttle_increment = 10
    @throttle_speed = 0
    @throttle_direction = 'f'
    @rudder_deflection = 0
    @rudder_direction = 'l'
    @elevator_deflection = 0
    @elevator_direction = 'u'
    @compass_heading = 0.0
    @autopilot_mode = 0
  end
  
  def connect(port)
    #@port_str = "/dev/tty.usbserial-A8007UEt"
    #port_str = "/dev/tty.usbserial-A700636n" # arduino via cable 
    # port_str = "/dev/tty.usbserial-A6007uob" # xbee explorer
    baud_rate = 19200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @sp = SerialPort.new(port, baud_rate, data_bits, stop_bits, parity)
    @sp.flow_control = SerialPort::SOFT
    @sp.read_timeout = 50
  end
  
  def disconnect
    @sp.close
    @sp = nil
  end
  
  def connected?
    @sp
  end
  
  def response
    @sp.read
  end
  
  # flying_robot command set
  def hail
    @sp.write "h\r"
  end
  
  def status
    @sp.write "s\r"
  end
  
  def set_throttle(direction, speed)
    @throttle_direction = direction
    @throttle_speed = speed
    send_throttle_command
  end
  
  def throttle_up
    if @throttle_direction == 'f'
      @throttle_speed = @throttle_speed + @throttle_increment
      if @throttle_speed > 100
        @throttle_speed = 100
      end
    else
      @throttle_speed = @throttle_speed - @throttle_increment
      if @throttle_speed < 0
        @throttle_direction = 'f'
        @throttle_speed = 0
      end
    end
    send_throttle_command
  end
  
  def throttle_down
    if @throttle_direction == 'f'
      @throttle_speed = @throttle_speed - @throttle_increment
      if @throttle_speed < 0
        @throttle_speed = 0
        @throttle_direction = 'r'
      end
    else
      @throttle_speed = @throttle_speed + @throttle_increment
      if @throttle_speed > 100
        @throttle_speed = 100
      end
    end
    send_throttle_command
  end
  
  def send_throttle_command
    @sp.write "t " + @throttle_direction + " " + @throttle_speed.to_s + "\r"
  end
  
  
  def set_rudder(direction, deflection)
    @rudder_direction = direction
    @rudder_deflection = deflection
    send_rudder_command
  end
  
  def rudder_left
    if @rudder_direction == 'l'
      @rudder_deflection = @rudder_deflection + @rudder_increment
      if @rudder_deflection > 90
        @rudder_deflection = 90
      end
    else
      @rudder_deflection = @rudder_deflection - @rudder_increment
      if @rudder_deflection <= 0
        @rudder_direction = 'l'
        @rudder_deflection = 0
      end
    end
    send_rudder_command
  end

  def rudder_right
    if @rudder_direction == 'r'
      @rudder_deflection = @rudder_deflection + @rudder_increment
      if @rudder_deflection > 90
        @rudder_deflection = 90
      end
    else
      @rudder_deflection = @rudder_deflection - @rudder_increment
      if @rudder_deflection <= 0
        @rudder_direction = 'r'
        @rudder_deflection = 0
      end
    end
    send_rudder_command
  end
  
  def send_rudder_command
    @sp.write "r " + @rudder_direction + " " + @rudder_deflection.to_s + "\r"
  end
  
  def set_elevator(direction, deflection)
    @elevator_direction = direction
    @elevator_deflection = deflection
    send_elevator_command
  end
  
  def elevator_up
    if @elevator_direction == 'u'
      @elevator_deflection = @elevator_deflection + @elevator_increment
      if @elevator_deflection > 45
        @elevator_deflection = 45
      end
    else
      @elevator_deflection = @elevator_deflection - @elevator_increment
      if @elevator_deflection <= 0
        @elevator_direction = 'u'
        @elevator_deflection = 0
      end
    end
    send_elevator_command
  end

  def elevator_down
    if @elevator_direction == 'd'
      @elevator_deflection = @elevator_deflection + @elevator_increment
      if @elevator_deflection > 45
        @elevator_deflection = 45
      end
    else
      @elevator_deflection = @elevator_deflection - @elevator_increment
      if @elevator_deflection <= 0
        @elevator_direction = 'd'
        @elevator_deflection = 0
      end
    end
    send_elevator_command
  end
  
  def send_elevator_command
    @sp.write "e " + @elevator_direction + " " + @elevator_deflection.to_s + "\r"
  end
  
  def stop
    set_throttle("f", 0)
    set_elevator("u", 0)
    set_rudder("l", 0)
  end
  
  def toggle_autopilot
    if @autopilot_mode == 0
      @autopilot_mode = 1
    elsif @autopilot_mode == 1
        @autopilot_mode = 2
    else
      @autopilot_mode = 0
    end
    @sp.write "a #{@autopilot_mode}\r"
  end
  
  def read_compass
    @sp.write "i c\r"
    @compass_heading = @sp.read
  end

  def read_battery
    @sp.write "i b\r"
    @battery_level = @sp.read
  end
end
