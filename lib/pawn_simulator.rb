require_relative 'piece'
require 'pry'

class PawnSimulator
  def initialize
    @pawn = Piece.new('pawn')
    @rook = Piece.new('rook')
  end

  def process(command)
    if command.include?("pawn")
      puts @pawn.execute(command)
    else
      puts @rook.execute(command)
    end
  end
end