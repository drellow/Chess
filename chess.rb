require 'colorize'
require 'debugger'


class Game

  KEY = {"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7}
  attr_accessor :game_board

  def run
    make_board
    @player1 = HumanPlayer.new(:red)
    @player2 = HumanPlayer.new(:blue)
    while true
      show_board
      puts "Red player go!"
      get_move(@player1)
      show_board
      puts "Blue player go!"
      get_move(@player2)
    end
  end

  def make_board
    @game_board = Array.new(8) do
      # create a blank row
      Array.new(8, nil)
    end
    @game_board[0] = [Rook.new(:red, 0, 0, self), Knight.new(:red, 0, 1, self), Bishop.new(:red, 0, 2, self), King.new(:red, 0, 3, self), Queen.new(:red, 0, 4, self), Bishop.new(:red, 0, 5, self), Knight.new(:red, 0, 6, self), Rook.new(:red, 0, 7, self)]
    8.times {|i| @game_board[1][i] =  Pawn.new(:red, 1, i, self)}
    8.times {|i| @game_board[6][i] =  Pawn.new(:blue, 6, i, self)}
    @game_board[7] = [Rook.new(:blue, 7, 0, self), Knight.new(:blue, 7, 1, self), Bishop.new(:blue, 7, 2, self), King.new(:blue, 7, 3, self), Queen.new(:blue, 7, 4, self), Bishop.new(:blue, 7, 5, self), Knight.new(:blue, 7, 6, self), Rook.new(:blue, 7, 7, self)]
  end

  def show_board
    @game_board.each_with_index do |row, index1|
      display_row = "#{(index1 - 8)*-1}  "
      row.each_with_index do |square, index2|
        if square.nil?
          display_row << "\u2610 "
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
  def check_move(potential_move, player_obj)
    # debugger
    valid_move = true
    move_coords = convert_coords(potential_move)
    start = @game_board[move_coords[0][0]][move_coords[0][1]]
    destination = @game_board[move_coords[1][0]][move_coords[1][1]]


    piece_destinations = start.possible_moves
    unless start.player == player_obj.player
      puts "That ain't your piece"
      valid_move = false
    end
    unless destination.nil?
      if destination.player == player_obj.player
        puts "Trying to move on top of your own piece"
        valid_move = false
      end
    end
    unless piece_destinations.include?([move_coords[1][0], move_coords[1][1]])
      puts "Your type of piece cannot move here"
      valid_move = false
    end
    valid_move
  end

  def get_move(player_obj)
    requested_move = player_obj.move

    if check_move(requested_move, player_obj)
      make_move(requested_move)
    else
      puts "Your move was invalid!"
      get_move(player_obj)
    end
  end

  #this doesn't check -- it just makes a move if it's valid.
  def make_move(move)
    # debugger
    move_coords = convert_coords(move)
    start = @game_board[move_coords[0][0]][move_coords[0][1]]
    destination = @game_board[move_coords[1][0]][move_coords[1][1]]

    start.row = (move_coords[1][0])
    start.column = (move_coords[1][1])
    @game_board[move_coords[1][0]][move_coords[1][1]] = start
    @game_board[move_coords[0][0]][move_coords[0][1]] = nil
  end

  # takes user move input as array of two string and converts it to
  # an array with two arrays each with a row and column coordinate
  # ex. ["2a", "3d"] => [[6, 0], [5, 3]]
  def convert_coords(move_array)
    return_array = []
    move_array.each do |position_string|
      return_sub_array = []
      return_sub_array << ((position_string[0].to_i)-8)*-1
      return_sub_array << KEY[position_string[1]]
      return_array << return_sub_array
    end
    p return_array
    return_array
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
end

class Knight < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2658".red : @token = "\u2658".blue
  end

  def possible_moves
    possible_moves = []
  end
end

class Pawn < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2659".red : @token = "\u2659".blue
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
    #go through move_array and make sure each value is in range 0-7
    move_array
  end

end

class Bishop < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2657".red : @token = "\u2657".blue
  end

  def possible_moves
    possible_moves = []
  end

end

class Rook < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2656".red : @token = "\u2656".blue
  end

  def possible_moves
    possible_moves = []
  end
end

class King < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2655".red : @token = "\u2655".blue
  end

  def possible_moves
    possible_moves = []
  end
end

class Queen < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    @player == :red ? @token = "\u2654".red : @token = "\u2654".blue
  end

  def possible_moves
    possible_moves = []
  end
end