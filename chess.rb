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
      show_board
      puts "Blue player go!"
      get_move(@player2)
      #save game here
      # File.open("save_chess_game.txt", "w") do |f|
      #   f.write(YAML.dump(self))
      # end
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
    @game_board[7] = [Rook.new(:blue, 7, 0, self), Knight.new(:blue, 7, 1, self), Bishop.new(:blue, 7, 2, self), King.new(:blue, 7, 3, self), Queen.new(:blue, 7, 4, self), Bishop.new(:blue, 7, 5, self), Knight.new(:blue, 7, 6, self), Rook.new(:blue, 7, 7, self)] #<< If I have time, I'll circle back to DRY
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

  #this doesn't check -- it just makes a move.
  #Always run this AFTER checks have been made
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
    return_array
  end

  # Returns an array of all surviving pieces on opposite team
  def opposing_forces(opposing_team)
    opposing_pieces = []
    @game_board.each do |row|
      row.each do |tile|
        if !tile.nil?
          if tile.player != opposing_team
            opposing_pieces << tile unless opposing_pieces.include?(tile)
          end
        end
      end
    end
    opposing_pieces
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
        break if @game.game_board[xdir][ydir] != nil
        break if !in_bounds?(xdir,ydir)
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
        break if @game.game_board[xdir][ydir] != nil
        break if !in_bounds?(xdir,ydir)
      end
    end
    arr
  end
end

class Knight < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    # @player == :red ? @token = "\u2658".red : @token = "\u2658".blue
    @player == :red ? @token = "k".red : @token = "k".blue
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
    # @player == :red ? @token = "\u2659".red : @token = "\u2659".blue
    @player == :red ? @token = "p".red : @token = "p".blue

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
    # @player == :red ? @token = "\u2657".red : @token = "\u2657".blue
    @player == :red ? @token = "b".red : @token = "b".blue

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
    # @player == :red ? @token = "\u2656".red : @token = "\u2656".blue
    @player == :red ? @token = "r".red : @token = "r".blue

  end

  def possible_moves
    possible_moves = horizontals(@row, @column)
  end
end

class King < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    # @player == :red ? @token = "\u2655".red : @token = "\u2655".blue
    @player == :red ? @token = "K".red : @token = "K".blue

  end

  def possible_moves
    possible_moves = circle(@row, @column)
    possible_moves.select {|move| check?(move[0],move[1]) == false }
  end

  def check?(x,y)
    #find all opposing pieces
    # debugger
    opposing_pieces = @game.opposing_forces(self.player)
    #find where every opposing piece can move
    targetable_spaces = []
    opposing_pieces.each do |piece|
      puts "#{piece.row},#{piece.column}"    
      targetable_spaces += piece.possible_moves
    end
    #king can not move to a space where an opposing player can go
    return true if targetable_spaces.include?([x,y])
    false #<< else return false
  end

end

class Queen < Piece
  attr_reader :token

  def initialize(player, row, column, game)
    super(player, row, column, game)
    # @player == :red ? @token = "\u2654".red : @token = "\u2654".blue
    @player == :red ? @token = "Q".red : @token = "Q".blue

  end

  def possible_moves
    possible_moves = diagonals(@row, @column) + horizontals(@row, @column)
  end
end