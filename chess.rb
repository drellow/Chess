require 'colorize'
require 'debugger'
require 'yaml'


class Game

  KEY = {"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7}
  attr_accessor :game_board

  def start
 #<< This includes the save/load feature, which is disabled.
  end

  def run
    make_board
    @player1 = HumanPlayer.new(:red)
    @player2 = HumanPlayer.new(:blue)
    while true
      show_board
      puts "Red player go!"
      get_move(@player1)
      # if checkmate?(:red)
      #   puts "FWIAJRER"
      # end
      show_board
      puts "Blue player go!"
      get_move(@player2)
      if checkmate?(:blue)
        puts "elahge;aesglhe"
      end
      #save game here
      # File.open("save_chess_game.txt", "w") do |f|
      #   f.write(YAML.dump(self))
      # end
    end
  end

  # def checkmate?(team)
  #   king = find_king(team)
  #   kingx, kingy = king.row, king.column

  #   checkmate = true
  #   team_members = forces(team)
  #   team_members.each do |piece|
  #     row = piece.row
  #     column = piece.column
  #     possible_moves = piece.possible_moves
  #     possible_moves.select! {|x,y| check_move([x,y], piece) == true}
  #     possible_moves.each do |x,y|
  #       safety_board = @game_board.dup

  #       make_move([[row, column], [x, y]])

  #       checkmate = false if !king.check?(team)
  #       @game_board = safety_board
  #     end
  #   end
  #   checkmate
  # end

  def find_king(team)
    @game_board.each do |x|
      x.each do |piece|
        return piece if piece.class == King && piece.player == team
      end
    end
  end

  def make_board
    @game_board = Array.new(8) do
      # create a blank row
      Array.new(8, nil)
    end
    @game_board[0] = [Rook.new(:red, 0, 0, self), Knight.new(:red, 0, 1, self), Bishop.new(:red, 0, 2, self), Queen.new(:red, 0, 3, self), King.new(:red, 0, 4, self), Bishop.new(:red, 0, 5, self), Knight.new(:red, 0, 6, self), Rook.new(:red, 0, 7, self)]
    8.times {|i| @game_board[1][i] =  Pawn.new(:red, 1, i, self)}
    8.times {|i| @game_board[6][i] =  Pawn.new(:blue, 6, i, self)}
    @game_board[7] = [Rook.new(:blue, 7, 0, self), Knight.new(:blue, 7, 1, self), Bishop.new(:blue, 7, 2, self), Queen.new(:blue, 7, 3, self), King.new(:blue, 7, 4, self), Bishop.new(:blue, 7, 5, self), Knight.new(:blue, 7, 6, self), Rook.new(:blue, 7, 7, self)] #<< If I have time, I'll circle back to DRY
  end

  def show_board
    @game_board.each_with_index do |row, index1|
      display_row = "#{(index1 - 8)*-1}  "
      row.each_with_index do |square, index2|
        if square.nil?
          # display_row << "\u2610 "
          display_row << "* "

        else
          display_row << square.token + " "
        end
      end
      puts display_row
    end
    puts
    puts "   a b c d e f g h"
    return nil
  end

  #this just returns true or false
  def check_move(move_coords, player_obj)
    # debugger
    start = @game_board[move_coords[0][0]][move_coords[0][1]]
    destination = @game_board[move_coords[1][0]][move_coords[1][1]]


    piece_destinations = start.possible_moves
    unless start.player == player_obj.player
      puts "That ain't your piece"
      return false
    end
    unless destination.nil?
      if destination.player == player_obj.player
        puts "Trying to move on top of your own piece"
        return false
      end
    end
    unless piece_destinations.include?([move_coords[1][0], move_coords[1][1]])
      puts "Your type of piece cannot move here"
      return false
    end
    # king = find_king(start.player)
    # backup_board = @game_board.dup
    # make_move(move_coords)
    # if king.check?(start.player) == true
    #   puts "cant put king into check"
    #   return false
    # end
    # @game_board = backup_board
    true
  end

 def get_move(player_obj)
    requested_move = player_obj.move
    move_coords = convert_coords(requested_move)

    if check_move(move_coords, player_obj)
      make_move(move_coords)
    else
      puts "Your move was invalid!"
      get_move(player_obj)
    end
  end

  #this doesn't check -- it just makes a move.
  #Always run this AFTER checks have been made
  def make_move(move_coords)
    # debugger
    start = @game_board[move_coords[0][0]][move_coords[0][1]]
    destination = @game_board[move_coords[1][0]][move_coords[1][1]]

    start.row = (move_coords[1][0])
    start.column = (move_coords[1][1])
    @game_board[move_coords[1][0]][move_coords[1][1]] = start
    @game_board[move_coords[0][0]][move_coords[0][1]] = nil
  end

  def convert_coords(move_array)
    return_array = []
    move_array.each do |position_string|
      return_sub_array = []
      return_sub_array << ((position_string[0].to_i)-8)*-1
      return_sub_array << KEY[position_string[1]]
      return_array << return_sub_array
    end
    return_array
  end

  # Returns an array of all surviving pieces on opposite team
  def forces(team)
    pieces = []
    @game_board.each do |row|
      row.each do |tile|
        if !tile.nil?
          if tile.player == team
            pieces << tile unless pieces.include?(tile)
          end
        end
      end
    end
    pieces
  end

end

class HumanPlayer

  attr_accessor :player

  def initialize(player)
    @player = player
  end

  def move
    puts "Move from what row / column"
    pos_from = gets.chomp
    puts "Move to what row / column"
    pos_to = gets.chomp

    return [pos_from, pos_to]
  end
end

class Piece
  attr_reader :player
  attr_accessor :row, :column

  def initialize(player, row, column, game)
    @player = player
    @row = row
    @column = column
    @game = game
  end

  def in_bounds?(x,y)
    (0..7).include?(x) && (0..7).include?(y)
  end

  def check?(team)
    # debugger
    if team == :red
      not_team = :blue
    else
      not_team = :red
    end
    king = @game.find_king(self.player)
    kingx = king.row
    kingy = king.column
    opposing_pieces = @game.forces(not_team)
    #find where every opposing piece can move
    targetable_spaces = []
    opposing_pieces.each do |piece|
      targetable_spaces += piece.possible_moves
    end
    #king can not move to a space where an opposing player can go
    return true if targetable_spaces.include?([kingx,kingy])
    false #<< else return false
  end

  def circle(x,y)
    directions = [[-1, 0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]]
    arr = []
    directions.each do |dir|
      xdir = x
      ydir = y
      xdir += dir[0]
      ydir += dir[1]
      arr << [xdir,ydir] if in_bounds?(xdir,ydir)
    end
    arr
  end

  #I repeat myself in horizontals and diagonals
  #Hopefully I'll be able to circle back and DRY this out.
  def horizontals(x,y)
    arr = []
    horizontals = [[-1, 0], [0, 1], [1, 0], [0,-1]]
    horizontals.each do |dir|
      xdir = x
      ydir = y
      while true
        xdir += dir[0]
        ydir += dir[1]
        arr << [xdir,ydir] if in_bounds?(xdir,ydir)
        break if !in_bounds?(xdir,ydir)
        break if @game.game_board[xdir][ydir] != nil
      end
    end
    arr
  end

  def diagonals(x,y)
    arr = []
    diagonals = [[-1, 1], [1, 1], [1, -1], [-1,-1]]
    diagonals.each do |dir|
      xdir = x
      ydir = y
      while true
        xdir += dir[0]
        ydir += dir[1]
        arr << [xdir,ydir] if in_bounds?(xdir,ydir)
        break if !in_bounds?(xdir,ydir)
        break if @game.game_board[xdir][ydir] != nil
      end
    end
    arr
  end
end

class Knight < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2658".red : @token = "\u2658".blue
    # @player == :red ? @token = "k".red : @token = "k".blue
  end

  def possible_moves
    possible_moves = []
    possible_moves << [@row + 2, @column + 1]
    possible_moves << [@row + 1, @column + 2]
    possible_moves << [@row + 1, @column - 2]
    possible_moves << [@row + 2, @column - 1]
    possible_moves << [@row - 1, @column - 2]
    possible_moves << [@row - 2, @column - 1]
    possible_moves << [@row - 2, @column + 1]
    possible_moves << [@row - 1, @column + 2]
    possible_moves
  end
end

class Pawn < Piece
  attr_reader :token


  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2659".red : @token = "\u2659".blue
    # @player == :red ? @token = "p".red : @token = "p".blue

    @first_move = true
    @starting_position = [row, column].dup
  end

  def possible_moves
    if @player == :red
      move_array = [[@row + 1, @column]]
      if @starting_position == [@row, @column]
        #can move 2 places this move
        move_array << [@row + 2, @column]
      end
      # diagonals
      if @game.game_board[@row + 1][@column + 1] != nil
        move_array << [@row + 1, @column + 1]
      end
      if @game.game_board[@row + 1][@column - 1] != nil
        move_array << [@row + 1, @column - 1]
      end
    else
      move_array = [[@row - 1, @column]]
      if @starting_position == [@row, @column]
        #can move 2 places this move
        move_array << [@row - 2, @column]
      end
      if @game.game_board[@row - 1][@column + 1] != nil
        move_array << [@row - 1, @column +1]
      end
      if @game.game_board[@row - 1][@column - 1] != nil
        move_array << [@row - 1, @column - 1]
      end
    end
    move_array
  end

end

class Bishop < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2657".red : @token = "\u2657".blue
    # @player == :red ? @token = "b".red : @token = "b".blue

  end

  def possible_moves
    starting_position = [@row, @column]
    possible_moves = diagonals(@row,@column)
  end

end

class Rook < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2656".red : @token = "\u2656".blue
    # @player == :red ? @token = "r".red : @token = "r".blue

  end

  def possible_moves
    possible_moves = horizontals(@row, @column)
  end
end

class King < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2654".red : @token = "\u2654".blue
    # @player == :red ? @token = "K".red : @token = "K".blue

  end

  def possible_moves
    possible_moves = circle(@row, @column)

  end



end

class Queen < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2655".red : @token = "\u2655".blue
    # @player == :red ? @token = "Q".red : @token = "Q".blue

  end

  def possible_moves
    possible_moves = diagonals(@row, @column) + horizontals(@row, @column)
  end
end