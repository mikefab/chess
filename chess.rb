class Game
  attr_accessor :board, :color_count
  def initialize
  @board = Board.new    
  @color_count = 0
  end
  def play
    loop do
      @board.paint_board                              #print chess board with pieces
      color = @color_count%2 == 0 ? 'white' : 'black'  #determine which color's turn it is
      puts "Please enter a start and destination square in the format of a2 e2 for #{color}: \n"
      input  = gets.strip
      break if input.match(/(q|'')/)                  #exit game if user enters q or nothing
      unless valid?(input)                            #Check that user has entered legitimate chess board start and finish coordinates
        puts "You did not input the correct format: a3 b4, for instance\n"
        next
      end
      start, stop = Square.convert_coordinates(input)
      #get actual squares
      start, stop = Square.get_squares_by_coordinates(start, stop, @board)
      turn(start, stop, color)                                    #input is valid, so move piece
    end
  end

  def valid?(input)
    if input.match(/^[a-hA-H][0-8]\s+[a-hA-H][0-8]$/) #make sure that input is valid chessboard coordinates
      true
    else
      false
    end	
  end

  def move(start, stop)                 #moves piece from start to destination square
    start.piece.moved = 1               #this is a cheap way to make sure that a pawn moves two spaces only on its first move. 
    stop.piece = start.piece            #Fill destination square with piece from start square
    start.piece = Piece.new(' ', ' ')   #leave start square empty
    @color_count+=1                            
  end

  def turn(start, stop, color)
    move(start, stop) if occupiable?(start, stop, color) #move piece if the destination square occupiable
  end
  
  def occupiable?(start, stop, color) #determines if destination square is occubiable
    y_diff = stop.y - start.y
    x_diff = stop.x - start.x
    
    unless start.piece.name.match(/p/i)
      puts "Sorry, only pawns can be moved at the moment."
      return false
    end
    
    unless start.piece.color == color[0]  #make sure that the user is moving the correct color piece
      puts "You must move #{color}."
      return false
    end
    unless start.piece.rules.include?([y_diff, x_diff]) #check that stop square is in range of start square for piece
      puts "The destination square is out of range of this #{start.piece.name}\n"
      return false
    end
    if start.piece.color == stop.piece.color #pieces of same color cannot replace each other
      puts "A piece cannot move to a square that has a piece of the same color.\n"
      return false
    end
    if start.piece.name == 'p' and x_diff != 0 #check conditions for pawn attack!
      if stop.piece.color == ' '
        puts "Conditions are not suitable for this pawn to attack."
        return false
      end
    end
    true 
  end
end

class Piece
  attr_accessor :name, :color, :moved
  def initialize(name, color)
    @name  = name   #p for pawn, k for knight..etc
    @color = color  #white or black
    @moved = 0      #way to keep track if pawn is allowed to move two spaces or just one
  end
	
  def rules                               #keep track of possible range per piece. For pawns only currently. 
    if self.name.match(/p/i)
      range = [ [1, 0], [1, -1], [1, 1] ]
      range << [2, 0] if self.moved == 0  #Add 2 spaces if its pawns first move
      return self.color == 'b' ? range : range.map!{|s| s.map!{|e| e*-1}} #unique to chess pieces, pawns move in one direction depending on color
    end
  end
  def to_s  #print out pieces name if it exists on a square
    @name
  end
end

class Square
  attr_reader :x, :y
  attr_accessor :piece #pawn, knight biship..etc
  def initialize(x, y)
    @x, @y = x, y
    case y  #line the b and g rows with pawns
    when 1
      @piece = Piece.new('p', 'b')
    when 6
      @piece = Piece.new('P', 'w')
    when 0, 7
      case x
      when 0, 7 
        @piece = Piece.new('r', 'b') if y == 0
        @piece = Piece.new('r', 'w') if y == 7
      when 1, 6
        @piece = Piece.new('b', 'b') if y == 0
        @piece = Piece.new('b', 'w') if y == 7

      when 2, 5
        @piece = Piece.new('k', 'b') if y == 0
        @piece = Piece.new('k', 'w') if y == 7

      when 3
        @piece = Piece.new('q', 'b') if y == 0
        @piece = Piece.new('q', 'w') if y == 7

      when 4
        @piece = Piece.new('K', 'b') if y == 0
        @piece = Piece.new('K', 'w') if y == 7
      else
        @piece = Piece.new(' ', ' ')
      end
    else
      @piece = Piece.new(' ', ' ')
    end
  end
	
  def Square.named(s) #for translating string coordinates to numbers. b3 -> 12
    [s.downcase.ord - ?a.ord, s[1].ord - ?1.ord]
  end

  def self.convert_coordinates(input)
    input.split(/\s+/).map{|arg| Square.named(arg)} #input is valid coordinates, convert something like a3 to xy coordinates
  end

  def self.get_squares_by_coordinates(start, stop, board)
    [start, stop].map{|coord| board.squares.select{|square| square.x == coord[1] and square.y == coord[0]}[0] }
  end

end

class Board
  attr_reader :squares
  ROW_HEADER = [1, 2, 3, 4, 5, 6, 7, 8]
  COL_HEADER = %w[a b c d e f g h]
  def initialize 
    @squares = (0...64).collect { |n| Square.new(n % 8, n / 8) }
  end

  def paint_board #print board for user to see
    print "  #{ROW_HEADER.join(' ')}\n"
    self.squares.each_slice(8).with_index do |row, index|
      print "#{COL_HEADER[index]} "
      row.map{|e| print "#{e.piece}|"}
      print "\n"
    end		
  end
end


Game.new.play