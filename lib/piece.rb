require 'pry'

class Piece
  attr_accessor :position, :direction, :color, :type

  DIRECTIONS= [:north, :east, :south, :west]
  COMMANDS= [:place, :left, :right, :report]
  COLORS = [:white, :black]
  @@pawn_position_locked = {}
  @@rook_position_locked = {}

  def initialize(type)
    @type = type
  end

  def place(x, y, direction, color)
    raise TypeError, 'Invalid coordinates' unless x.is_a? Integer and y.is_a? Integer
    raise TypeError, 'Invalid direction' unless DIRECTIONS.include?(direction)
    raise TypeError, 'Invalid color' unless COLORS.include?(color)
    if check_valid_position?(x,y)
      @double_move = true
      @position = { x: x, y: y }
      @direction = direction
      if check_allocated_position_during_place?
        @color = color
        @@pawn_position_locked = @position if self.type.eql?("pawn")
        @@rook_position_locked = @position if self.type.eql?("rook")
        true
      else
        return "there is an object already occupied, you should not place this #{self.type.capitalize} here"
      end
    else
      false
    end
  end


  def move(value=1)
    return "#{self.type.capitalize} is not placed yet, try running place command first" if @position.nil? or @direction.nil? or @color.nil?
    return false if @position.nil?
    return "you should not move 2 squares here after as this is pawn" if !@double_move && value.eql?(2)

    position = @position
    movement = nil

    case @direction
    when :north
      movement = value.eql?(1) ? { x: 0, y: 1} : { x: 0, y: 2 } if self.type.eql?("pawn")
      movement = value.eql?(1) ? { x: 0, y: 1} : { x: 0, y: value } if self.type.eql?("rook")
    when :east
      movement = value.eql?(1) ? { x: 1, y: 0} : { x: 2, y: 0 } if self.type.eql?("pawn")
      movement = value.eql?(1) ? { x: 0, y: 1} : { x: value, y: 0 } if self.type.eql?("rook")
    when :south
      movement = value.eql?(1) ? { x: 0, y: -1} : { x: 0, y: -2 } if self.type.eql?("pawn")
      movement = value.eql?(1) ? { x: 0, y: 1} : { x: 0, y: -value } if self.type.eql?("rook")
    when :west
      movement = value.eql?(1) ? { x: -1, y: 0} : { x: -2, y: 0 } if self.type.eql?("pawn")
      movement = value.eql?(1) ? { x: 0, y: 1} : { x: -value, y: 0 } if self.type.eql?("rook")
    end

    move_complete = true
    x,y = position[:x] + movement[:x], position[:y] + movement[:y]

    if check_valid_position?(x,y)
      if check_allocated_position_during_move?({x: x, y: y})
        @position = { x: position[:x] + movement[:x], y: position[:y] + movement[:y] }

        @@pawn_position_locked = @position if self.type.eql?("pawn")
        @@rook_position_locked = @position if self.type.eql?("rook")

        if value.odd?
          color_index = COLORS.index(@color)
          @color = COLORS.rotate()[color_index]
        end
      else
        message = "there is an object already occupied, you should not place this #{self.type.capitalize} here"
        move_complete = false
      end
    else
      message = "You should not move as #{self.type.capitalize} will fell down"
      move_complete = false
    end

    @double_move = false if self.type.eql?("pawn")
    move_complete ? move_complete : message
  end

  def move_position(command)
    return "#{self.type.capitalize} is not placed yet, try running place command first" if @position.nil? or @direction.nil? or @color.nil?
    return false if @direction.nil?
    position_index = DIRECTIONS.index(@direction)

    @direction = command.to_s.eql?("left") ? DIRECTIONS.rotate(-1)[position_index] : DIRECTIONS.rotate()[position_index]
    true
  end

  def report
    return "#{self.type.capitalize} is not placed yet, try running place command first" if @position.nil? or @direction.nil? or @color.nil?

    "Current Position: #{@position[:x]},#{@position[:y]},#{@direction.to_s.upcase},#{@color.to_s.upcase}"
  end

  def execute(params)
    return if params.strip.empty?

    args = params.split(/\s+/)
    piece_type = args.first
    command = args[1].to_s.downcase.to_sym
    arguments = args.last

    raise ArgumentError, 'Invalid command' unless COMMANDS.include?(command) || command.to_s.include?("move")

    if (["move(2)","move(3)","move(4)","move(5)","move(6)","move(7)"].include?(command.to_s) && self.type.eql?("rook")) || (command.to_s.eql?("move(2)") && self.type.eql?("pawn"))
      position = command.to_s.split("(")[1].gsub!(")","").to_i
      command = :move_with_position
    elsif command.to_s.eql?("move(1)")
      command = :move
    end

    case command
    when :place
      raise ArgumentError, 'Invalid command' if arguments.nil?

      tokens = arguments.split(/,/)

      raise ArgumentError, 'Invalid command' unless tokens.count > 3

      x = tokens[0].to_i
      y = tokens[1].to_i
      direction = tokens[2].downcase.to_sym
      color = tokens[3].downcase.to_sym

      place(x, y, direction, color)
    when :move
      move
    when :left
      move_position("left")
    when :right
      move_position("right")
    when :report
      report
    when :move_with_position
      move(position)
    else
      raise ArgumentError, 'Invalid command'
    end
  end

  private

  def check_valid_position?(x,y)
    (x>=0 && x<=7 && y>=0 && y<=7)
  end

  def check_allocated_position_during_place?
    check = ((@@pawn_position_locked == @position) || (@@rook_position_locked == @position)) ? false : true
    return check
  end

  def check_allocated_position_during_move?(position)
    check = ((@@pawn_position_locked == position) || (@@rook_position_locked == position)) ? false : true
    return check
  end

end
