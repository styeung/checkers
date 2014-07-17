require_relative 'piece'
require 'colorize'

class Board
  attr_accessor :grid

  def initialize()
    @grid = Array.new(8) {Array.new(8)}

    (0...8).each do |row|
      (0...8).each do |column|
        if row < 3 && (row % 2 != column % 2)
          Piece.new(self, [row, column], false, :black)
        end

        if row > 4 && (row % 2 != column % 2)
          Piece.new(self, [row, column], false, :red)
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
          if column.between?(1,8)
            print " #{column_hash[column]} "
          else
            print "   "
          end
        elsif column == 0 || column == 9
          if row.between?(1,8)
            print " #{row} "
          else
            print "   "
          end
        else
          pos = [row - 1, column - 1]
          if pos[0] % 2 != pos[1] % 2
            if !self[pos].nil?
              print " ☻ ".colorize(:color => self[pos].color, :background => :light_black)
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