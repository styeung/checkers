require_relative 'piece'
require 'colorize'

class Board
  attr_accessor :grid, :pieces

  def initialize(empty = false)
    @grid = Array.new(8) {Array.new(8)}
    @pieces = []

    if !empty
      (0...8).each do |row|
        (0...8).each do |column|
          if row < 3 && (row % 2 != column % 2)
            Piece.new(self, [row, column], false, :red)
          end

          if row > 4 && (row % 2 != column % 2)
            Piece.new(self, [row, column], false, :black)
          end
        end
      end
    end
  end

  def [](pos)
    row, column = pos
    self.grid[row][column]
  end

  def []=(pos, piece)
    row, column = pos
    self.grid[row][column] = piece
  end

  def deep_dup
    new_board = Board.new(true)
    self.grid.each do |row|
      row.each do |space|
        if !space.nil?
          Piece.new(new_board, space.pos.dup, space.king_status, space.color)
        end
      end
    end

    new_board
  end

  def no_more_moves?(color)
    team_pieces = self.deep_dup.pieces.select {|piece| piece.color == color}
    team_pieces.all? {|piece| piece.move_diffs.empty? }
  end

  def no_more_pieces?(color)
    self.deep_dup.pieces.none? {|piece| piece.color == color}
  end


  def render
    column_hash = {
      1 => "a",
      2 => "b",
      3 => "c",
      4 => "d",
      5 => "e",
      6 => "f",
      7 => "g",
      8 => "h"
    }

    (0...10).each do |row|
      (0...10).each do |column|
        if row == 0 || row == 9
          print column.between?(1,8) ? " #{column_hash[column]} " : "   "
        elsif column == 0 || column == 9
          print row.between?(1,8) ? " #{row} " : "   "
        else
          pos = [row - 1, column - 1]
          if pos[0] % 2 != pos[1] % 2
            if !self[pos].nil?
              if self[pos].king_status
                print " Ⓚ ".colorize(:color => self[pos].color, :background => :light_black)
              else
                print " ☻ ".colorize(:color => self[pos].color, :background => :light_black)
              end
            else
              print "   ".colorize(:background => :light_black)
            end
          else
            print "   "
          end
        end
      end

      puts
    end

  end

end