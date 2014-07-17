require_relative 'board'
require 'debugger'
require 'yaml'

class Game
  attr_accessor :board, :current_color, :turn

  TURN_ARRAY = [:black, :red]

  def initialize(board = Board.new)
    @board = board
    @current_color = :black
    @turn = 0
  end

  def play
    until self.over?(self.current_color)
      begin
        self.board.render
        self.current_color = TURN_ARRAY[self.turn % 2]
        puts "#{self.current_color.capitalize} turn"
        puts "Enter your move list separated by spaces or press 's' to save"
        response = gets.chomp

        if response == "s"
          puts "Enter in a name for the save file"
          file_name = gets.chomp
          File.open("#{file_name}.yaml", "w") {|f| f.write self.to_yaml }
          next
        end

        move_list = parse_response(response)

        first_position = move_list[0]
        if self.board[first_position].color != self.current_color
          raise InvalidMoveError.new("That is not your piece")
        end

        self.board[first_position].perform_moves(move_list)
      rescue InvalidMoveError => e
        puts e.message
        puts "Please try again"
        retry
      end

      opponent_color = TURN_ARRAY[(self.turn + 1) % 2]
      if self.over?(opponent_color)
        puts "#{self.current_turn.capitalize} wins!"
      end

      self.turn += 1
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

if __FILE__ == $PROGRAM_NAME
  if ARGV[0].nil?
    game = Game.new
    game.play
  else
    game = YAML::load_file(ARGV.shift)
    game.play
  end
end