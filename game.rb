require_relative 'board'
require 'debugger'

class Game
  attr_accessor :board, :current_turn

  def initialize
    @board = Board.new
    @current_turn = :black
  end

  def play
    turn_array = [:black, :red]
    turn = 0

    until self.over?(self.current_turn)
      begin
        self.board.render
        self.current_turn = turn_array[turn % 2]
        puts "#{self.current_turn.capitalize} turn"
        puts "Enter your move list separated by spaces"
        response = gets.chomp
        move_list = parse_response(response)
        self.board[move_list[0]].perform_moves(move_list)
      rescue InvalidMoveError => e
        puts e.message
        puts "Please try again"
        retry
      end

      opponent_color = turn_array[(turn + 1) % 2]
      if self.over?(opponent_color)
        puts "#{self.current_turn.capitalize} wins!"
      end

      turn += 1
    end
  end

  def parse_response(response)
    parse_hash = {
      "a" => 0,
      "b" => 1,
      "c" => 2,
      "d" => 3,
      "e" => 4,
      "f" => 5,
      "g" => 6,
      "h" => 7,
      "1" => 0,
      "2" => 1,
      "3" => 2,
      "4" => 3,
      "5" => 4,
      "6" => 5,
      "7" => 6,
      "8" => 7,
    }

    output_array = []

    response.split(" ").each do |coordinate|
      row = coordinate[0]
      column = coordinate[1]
      if parse_hash[row].nil? || parse_hash[column].nil?
        raise InvalidMoveError.new("Invalid input")
      else
        output_array << [parse_hash[row], parse_hash[column]]
      end
    end

    output_array
  end

  def over?(color)
    return true if self.board.no_more_moves?(color)
    return true if self.board.no_more_pieces?(color)
  end


end