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

  end

  def perform_jump(end_pos)
    start_pos = self.pos
    new_piece = Piece.new(self.board, end_pos, self.king_status, self.color)
    self.board[start_pos] = nil

    enemy_pos = [(start_pos[0] + end_pos[0]) / 2 , (start_pos[0] + end_pos[0]) / 2]
    self.board[enemy_pos] = nil
  end

  def move_diffs
    deltas = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ]
    direction_array = []

    deltas.each do |delta|
      current_pos = self.pos

      if self.color == :red && new_row > current_pos
        next if self.king_status == false
      elsif self.color == :black && new_row < current_pos
        next if self.king_status == false
      end

      if self.board[new_row, new_column].nil?
        direction_array << delta
      elsif self.board[new_row, new_column].color != self.color
        direction_array << [delta[0] * 2, delta[1] * 2
      end
    end

    direction_array
  end

  def moves

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