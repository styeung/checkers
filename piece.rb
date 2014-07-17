require_relative 'board'
require 'debugger'

class Piece
  attr_accessor :board, :pos, :king_status, :color

  def initialize(board, pos, king_status, color)
    @board = board
    @pos = pos
    @king_status = king_status
    @color = color

    @board[pos] = self
  end

  def perform_slide(end_pos)
    start_pos = self.pos
    new_piece = Piece.new(self.board, end_pos, self.king_status, self.color)
    self.board[start_pos] = nil
    self.board.render
  end

  def perform_jump(end_pos)
    start_pos = self.pos
    new_piece = Piece.new(self.board, end_pos, self.king_status, self.color)
    self.board[start_pos] = nil

    enemy_pos = [(start_pos[0] + end_pos[0]) / 2 , (start_pos[1] + end_pos[1]) / 2]

    p "enemy before #{self.board[enemy_pos].class}"
    self.board[enemy_pos] = nil
    p "enemy after #{self.board[enemy_pos].class}"

    self.board.render
  end

  def move_diffs(type = nil)
    deltas = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ]
    direction_array = []

    deltas.each do |delta|
      current_pos = self.pos
      new_row = current_pos[0] + delta[0]
      new_column = current_pos[1] + delta[1]

      if type == :slide || type.nil?
        if self.color == :black && new_row > current_pos
          next if self.king_status == false
        elsif self.color == :red && new_row < current_pos
          next if self.king_status == false
        end
      end

      if type == :jump || type.nil?

        if self.board[new_row, new_column].nil?
          direction_array << delta
        elsif self.board[new_row, new_column].color != self.color
          direction_array << [delta[0] * 2, delta[1] * 2]
        end
      end
    end

    direction_array
  end

  def perform_moves!(move_sequence)
    #move_sequence is an array of pos
    new_board = self.board.deep_dup
    if move_sequence.length < 2
      raise InvalidMoveError.new("You did not choose an end position")
    elsif move_sequence.length == 2
      start_pos = move_sequence[1]
      next_move = move_sequence[0]

      if !new_board[start_pos].move_diffs.include?(next_move)
        raise InvalidMoveError.new("You cannot move there")
      end
    elsif move_sequence.length > 2
      #makes sure each move is a jump
      (0...move_sequence.length).each do |num|
        unless num == 0
          if !move_sequence[num - 1].is_jump?(move_sequence[num])
            raise InvalidMoveError.new("You cannot mix slides and jumps")
          end
        end
      end

      start_pos = move_sequence.shift
      next_move = move_sequence[0]

      if !new_board[start_pos].move_diffs.include?(next_move)
        raise InvalidMoveError.new("You cannot move there")
      else
        new_board[start_pos].perform_slide(next_move) if

  end

  def is_jump?(end_pos)
    row_diff = (self[0] - end_pos[0]).abs
    col_diff = (self[1] - end_pos[1]).abs

    raise InvalidMoveError.new("Not a valid move") if row_diff != col_diff

    return true if row_diff > 1

    return false
  end

  def valid_move_seq?

  end

  def maybe_promote
    if self.pos[0] == 0
      if self.color == :red
        return true
      end
    elsif self.pos[0] == 7
      if self.color == :black
        return true
      end
    end

    return false

  end

end