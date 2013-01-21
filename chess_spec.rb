require 'rspec'
require_relative 'chess'

describe Game do

	subject(:game) {Game.new}

	describe "#check_move" do
		it "should return false when moving opponent piece" do
			game.make_board
			player_obj = game.game_board[1][0]
			game.check_move(["2b", "4b"], player_obj).should == false
		end

		it "should not let you move on top of your own piece" do
			game.make_board
			player_obj = game.game_board[0][0]
			game.check_move(["8a", "7a"], player_obj).should == false
		end

		it "should not allow rook to move illegally" do
			game.make_board
			game.game_board[1][1] = nil
			player_obj = game.game_board[0][0]
			game.check_move(["8a", "6c"], player_obj).should == false
		end

		it "should allow rook to move legally" do
			game.make_board
			game.game_board[1][0] = nil
			player_obj = game.game_board[0][0]
			game.check_move(["8a", "3a"], player_obj).should == true
		end

		it "should not allow knight to move illegally" do
			game.make_board
			player_obj = game.game_board[0][1]
			game.check_move(["8b", "6b"], player_obj).should == false
		end

		it "should allow knight to move legally" do
			game.make_board
			player_obj = game.game_board[0][1]
			game.check_move(["8b", "6a"], player_obj).should == true
		end

		it "should not allow bishop to move illegally" do
			game.make_board
			game.game_board[1][2] = nil
			player_obj = game.game_board[0][2]
			game.check_move(["8c", "7c"], player_obj).should == false
		end

		it "should allow bishop to move legally" do
			game.make_board
			player_obj = game.game_board[0][1]
			game.game_board[1][3] = nil
			game.check_move(["8c", "3h"], player_obj).should == true
		end

		it "should not allow queen to move legally"
		it "should allow queen to move legally"
		it "should not allow king to move illegally"
		it "should allow king to move legally"
	


	end

	describe "#opposing_forces" do
		it "should find all 16 players" do
			game.make_board
			opposite_team = game.opposing_forces(:red)
			opposite_team.count.should == 16
		end
	end
	
end