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

  it 'should only accept arguments in the appropriate format like "g2 e2"' do
    subject.valid?("g2 e2").should  == true
    subject.valid?("g2e2").should   == false
    subject.valid?("g2 e22").should == false
  end

  it 'should allow movement of pawns' do
    start, stop = Square.convert_coordinates("g2 e2")
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
