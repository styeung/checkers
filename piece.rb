require_relative 'board'
require 'debugger'

class InvalidMoveError < StandardError
end

class Piece
  attr_accessor :board, :pos, :king_status, :color

  def initialize(board, pos, king_status, color)
    @board = board
    @pos = pos
    @king_status = king_status
    @color = color

    @board[pos] = self
    @board.pieces << self
  end

  def perform_slide(end_pos)
    start_pos = self.pos
    king_boolean = false

    if end_pos[0] == 0
      if self.color == :black
        king_boolean = true
      end
    elsif self.pos[0] == 7
      if self.color == :red
        king_boolean = true
      end
    end

    new_piece = Piece.new(self.board, end_pos, king_boolean, self.color)
    self.board[start_pos] = nil

    p new_piece.king_status
    p self.board[end_pos].king_status

  end

  def perform_jump(end_pos)
    start_pos = self.pos
    king_boolean = false

    if end_pos[0] == 0
      if self.color == :black
        king_boolean = true
      end
    elsif self.pos[0] == 7
      if self.color == :red
        king_boolean = true
      end
    end

    new_piece = Piece.new(self.board, end_pos, king_boolean, self.color)
    self.board[start_pos] = nil

    enemy_pos = [(start_pos[0] + end_pos[0]) / 2 , (start_pos[1] + end_pos[1]) / 2]

    self.board.pieces -= [self.board[enemy_pos]]
    p self.board.pieces.count
    self.board[enemy_pos] = nil
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
      next_row = current_pos[0] + delta[0]
      next_column = current_pos[1] + delta[1]
      next_next_row = current_pos[0] + delta[0] * 2
      next_next_column = current_pos[1] + delta[1] * 2

      next_pos = [next_row, next_column]
      next_next_pos = [next_next_row, next_next_column]

      if self.color == :black && next_row > current_pos[0]
        next if self.king_status == false
      elsif self.color == :red && next_row < current_pos[0]
        next if self.king_status == false
      end

      if type == :slide || type.nil?
        next if !next_row.between?(0,7) || !next_column.between?(0,7)
        if self.board[next_pos].nil?
          direction_array << next_pos
        end
      end

      if type == :jump|| type.nil?
        next if !next_next_row.between?(0,7) || !next_next_column.between?(0,7)
        if !self.board[next_pos].nil? && self.board[next_pos].color != self.color
          if self.board[next_next_pos].nil?
            new_pos_with_jump = [next_next_row, next_next_column]
            direction_array << new_pos_with_jump
          end
        end
      end

    end

    direction_array
  end

  def perform_moves(move_sequence)
    if self.valid_move_seq?(move_sequence.dup)
      self.perform_moves!(move_sequence)
    else
      raise InvalidMoveError.new("Invalid moves")
    end
  end

  def perform_moves!(move_sequence)
    #move_sequence is an array of pos

    if move_sequence.length < 2
      raise InvalidMoveError.new("You did not choose an end position")
    elsif move_sequence.length == 2
      start_pos = move_sequence[0]
      next_move = move_sequence[1]

      if !self.board[start_pos].move_diffs.include?(next_move)
        raise InvalidMoveError.new("You cannot move there")
      else
        #need to make sure all jumps are completed if the move was a jump
        if self.is_jump?(start_pos, next_move)
          self.board[start_pos].perform_jump(next_move)

          if !self.board[next_move].move_diffs.empty?
            p "next_move is #{next_move}"
            p self.board[next_move].move_diffs
            raise InvalidMoveError.new("You need to complete all jumps")
          end
        else
          self.board[start_pos].perform_slide(next_move)
        end
      end


    elsif move_sequence.length > 2
      #makes sure each move is a jump
      (0...move_sequence.length).each do |num|
        unless num == 0
          if !self.is_jump?(move_sequence[num - 1], move_sequence[num])
            raise InvalidMoveError.new("You cannot mix slides and jumps")
          end
        end
      end

      start_pos = move_sequence.shift
      next_move = move_sequence[0]

      if !self.board[start_pos].move_diffs(:jump).include?(next_move)
        raise InvalidMoveError.new("You cannot move there")
      else
        self.board[start_pos].perform_jump(next_move)
        self.board[next_move].perform_moves!(move_sequence.dup)
      end
    end

  end

  def is_jump?(start_pos, end_pos)
    row_diff = (start_pos[0] - end_pos[0]).abs
    col_diff = (start_pos[1] - end_pos[1]).abs

    raise InvalidMoveError.new("Not a valid move") if row_diff != col_diff

    return true if row_diff > 1

    return false
  end

  def valid_move_seq?(move_sequence)
    new_board = self.board.deep_dup

    begin
      new_board[self.pos].perform_moves!(move_sequence)
    rescue InvalidMoveError => e
      p e.message
      return false
    else
      return true
    end
  end

  def is_king?
    if self.pos[0] == 0
      if self.color == :black
        return true
      end
    elsif self.pos[0] == 7
      if self.color == :red
        return true
      end
    end

    return false

  end

end