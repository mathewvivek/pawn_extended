require 'spec_helper'

describe Piece do
  let(:pawn) { Piece.new("pawn") }
  let(:rook) { Piece.new("rook") }

  context 'before place command' do
    it 'should return the pawn not placed message' do
      expect(pawn.execute("pawn report")).to eq("Pawn is not placed yet, try running place command first")
      expect(pawn.execute("pawn move")).to eq("Pawn is not placed yet, try running place command first")
      expect(pawn.execute("pawn left")).to eq("Pawn is not placed yet, try running place command first")
      expect(pawn.execute("pawn right")).to eq("Pawn is not placed yet, try running place command first")
    end

    it 'should return the rook not placed message' do
      expect(rook.execute("rook report")).to eq("Rook is not placed yet, try running place command first")
      expect(rook.execute("rook move")).to eq("Rook is not placed yet, try running place command first")
      expect(rook.execute("rook left")).to eq("Rook is not placed yet, try running place command first")
      expect(rook.execute("rook right")).to eq("Rook is not placed yet, try running place command first")
    end
  end

  context 'during place command' do
    it 'should place the pawn properly' do
      expect(pawn.execute('pawn place 1,2,NORTH,WHITE')).to eq(true)
      expect(pawn.position).to eq({:x=>1, :y=>2})
      expect(pawn.direction).to eq(:north)
      expect(pawn.color).to eq(:white)
      expect(pawn.execute("pawn report")).to eq("Current Position: 1,2,NORTH,WHITE")
    end

    it 'should place the rook properly' do
      expect(rook.execute('rook place 5,5,EAST,BLACK')).to eq(true)
      expect(rook.position).to eq({:x=>5, :y=>5})
      expect(rook.direction).to eq(:east)
      expect(rook.color).to eq(:black)
      expect(rook.execute("rook report")).to eq("Current Position: 5,5,EAST,BLACK")
    end
  end

  context 'after place command' do

    it 'move the pawn correspondingly: 2 squares first time only' do
      expect(pawn.execute('pawn place 3,3,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn move(2)')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 5,3,EAST,BLACK")
      expect(pawn.execute('pawn move(2)')).to eq("you should not move 2 squares here after as this is pawn")
    end

    it 'move the pawn correspondingly: should not allow 2 moves after a move command' do
      expect(pawn.execute('pawn place 6,6,WEST,BLACK')).to eq(true)
      expect(pawn.execute('pawn move')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 5,6,WEST,WHITE")
      expect(pawn.execute('pawn move(2)')).to eq("you should not move 2 squares here after as this is pawn")
    end

    it 'move the pawn correspondingly: should accept place command again' do
      expect(pawn.execute('pawn place 2,4,SOUTH,BLACK')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 2,4,SOUTH,BLACK")
      expect(pawn.execute('pawn place 7,7,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 7,7,EAST,BLACK") 
    end

    it 'move the pawn correspondingly: try moving left direction' do
      expect(pawn.execute('pawn place 3,3,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn left')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 3,3,NORTH,BLACK")
    end

    it 'move the pawn correspondingly: try moving right direction' do
      expect(pawn.execute('pawn place 6,6,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn right')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 6,6,SOUTH,BLACK")
    end

    it 'move the pawn correspondingly: pawn should not fell down' do
      expect(pawn.execute('pawn place 1,1,WEST,BLACK')).to eq(true)
      expect(pawn.execute('pawn move(2)')).to eq("You should not move as Pawn will fell down")
    end

    it 'move the rook correspondingly: n squares any time' do
      expect(rook.execute('rook place 0,0,NORTH,WHITE')).to eq(true)
      expect(rook.execute('rook move(3)')).to eq(true)
      expect(rook.execute('rook report')).to eq("Current Position: 0,3,NORTH,BLACK")
      expect(rook.execute('rook move(4)')).to eq(true)
      expect(rook.execute('rook report')).to eq("Current Position: 0,7,NORTH,BLACK")
    end

    it 'move the rook correspondingly: try moving left direction' do
      expect(rook.execute('rook place 2,2,NORTH,WHITE')).to eq(true)
      expect(rook.execute('rook left')).to eq(true)
      expect(rook.execute('rook report')).to eq("Current Position: 2,2,WEST,WHITE")
    end

    it 'move the rook correspondingly: try moving right direction' do
      expect(rook.execute('rook place 7,4,SOUTH,BLACK')).to eq(true)
      expect(rook.execute('rook right')).to eq(true)
      expect(rook.execute('rook report')).to eq("Current Position: 7,4,WEST,BLACK")
    end

    it 'move the rook correspondingly: rook should not fell down' do
      expect(rook.execute('rook place 7,7,NORTH,BLACK')).to eq(true)
      expect(rook.execute('rook move')).to eq("You should not move as Rook will fell down")
    end

    it 'place both pawn and rook' do
      expect(rook.execute('rook place 1,6,NORTH,BLACK')).to eq(true)
      expect(rook.execute('rook report')).to eq("Current Position: 1,6,NORTH,BLACK")
      expect(pawn.execute('pawn place 6,1,WEST,BLACK')).to eq(true)
      expect(pawn.execute('pawn report')).to eq("Current Position: 6,1,WEST,BLACK")
    end

    it 'do not place pawn when rook is there and vice_versa' do
      expect(rook.execute('rook place 3,7,NORTH,BLACK')).to eq(true)
      expect(pawn.execute('pawn place 3,7,WEST,BLACK')).to eq("there is an object already occupied, you should not place this Pawn here")
      expect(pawn.execute('pawn place 1,5,WEST,BLACK')).to eq(true)
      expect(rook.execute('rook place 1,5,SOUTH,BLACK')).to eq("there is an object already occupied, you should not place this Rook here")
    end

    it 'do not move into occupied location when you try to move rook' do
      expect(pawn.execute('pawn place 6,4,NORTH,BLACK')).to eq(true)
      expect(rook.execute('rook place 6,3,NORTH,BLACK')).to eq(true)
      expect(rook.execute('rook move')).to eq("there is an object already occupied, you should not place this Rook here")
    end

    it 'do not move into occupied location when you try to move pawn' do
      expect(rook.execute('rook place 1,3,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn place 0,3,EAST,BLACK')).to eq(true)
      expect(pawn.execute('pawn move')).to eq("there is an object already occupied, you should not place this Pawn here")
    end
  end

  context 'invalid coordinates and commands' do
    it 'out of range co-ordinates' do
      expect(pawn.execute('pawn place 0,-2,EAST,BLACK')).to eq(false)
      expect(rook.execute('rook place 9,6,SOUTH,WHITE')).to eq(false)
    end

    it 'Invalid commands' do
      expect{pawn.execute('pawn reportt')}.to raise_error(ArgumentError)
      expect{rook.execute('rook lefftt')}.to raise_error(ArgumentError)
    end
  end
end
