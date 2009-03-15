class FlyingRobotProxy
  attr_reader :throttle_speed, :throttle_direction, :rudder_direction, :rudder_deflection, :elevator_direction, :elevator_deflection
  
  def initialize(sp)
    @throttle_speed = 0
    @throttle_direction = 'f'
    @rudder_deflection = 0
    @rudder_direction = 'l'
    @elevator_deflection = 0
    @elevator_direction = 'u'
    @sp = sp
  end
  
  def hail
    @sp.write "h\r"
  end
  
  def status
    @sp.write "s\r"
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
    @sp.write "t " + @throttle_direction + " " + @throttle_speed.to_s + "\r"
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
    @sp.write "t " + @throttle_direction + " " + @throttle_speed.to_s + "\r"
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
    @sp.write "r " + @rudder_direction + " " + @rudder_deflection.to_s + "\r"
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
    @sp.write "r " + @rudder_direction + " " + @rudder_deflection.to_s + "\r"
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
    @sp.write "e " + @elevator_direction + " " + @elevator_deflection.to_s + "\r"
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
    @sp.write "e " + @elevator_direction + " " + @elevator_deflection.to_s + "\r"
  end
  
end
