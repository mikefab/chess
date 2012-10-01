require './chess'
require 'stringio'

describe 'game' do
  subject {Game.new}

  it "should be able to create a new instance" do
    lambda { Game.new }.should_not raise_error
  end

  it 'should create a chess board with 64 squares' do
    subject.board.squares.size.should == 64
  end

  it 'should have the right pieces in the right spots at the start of the game' do
    pieces = {
                'r' => [[0, 0, 'b'], [0, 7, 'b'],[7, 0, 'w'], [7, 7, 'w']],
                'b' => [[0, 1, 'b'], [0, 6, 'b'],[7, 1, 'w'], [7, 6, 'w']],
                'k' => [[0, 2, 'b'], [0, 5, 'b'],[7, 2, 'w'], [7, 5, 'w']],                
                'q' => [[0, 3, 'b'], [7, 3, 'w']],                
                'K' => [[0, 4, 'b'], [7, 4, 'w']]                
              }
    pieces.each do |piece, coords|
      coords.each do |coord|
        square = subject.board.squares.select{|square| square.x == coord[1] and square.y == coord[0]}[0]
        square.piece.name.should == piece
        square.piece.color.should == coord[2]
        
      end
    end
  end

  it 'should only accept arguments in the appropriate format like "g2 e2"' do
    subject.valid?("g2 e2").should  == true
    subject.valid?("g2e2").should   == false
    subject.valid?("g2 e22").should == false
  end

  it 'should allow movement of pawns' do
    start, stop = Square.convert_coordinates("g2 e2") #g2 e2 are the coordinates for a square with a pawn
    start, stop = Square.get_squares_by_coordinates(start, stop, subject.board)
    start.piece.name.should == 'P' #should be a pawn
    subject.occupiable?(start, stop, 'w').should == true
  end

  it 'should not allow movements of pieces that are not pawns' do
    start, stop = Square.convert_coordinates("h1 f2")
    start, stop = Square.get_squares_by_coordinates(start, stop, subject.board)
    start.piece.name.should == 'r' #should be a rook
    subject.occupiable?(start, stop, 'b').should == false
  end
end
