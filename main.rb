class Magazine
  # private, etc
  @@formats = {UNKNOWN: :UNKNOWN, NORMAL: :NORMAL}

  attr_reader :name, :signature, :length, :format, :block_size, :reserve

  def initialize(name, signature, length, block_size, format = @@formats[:NORMAL], reserve = 0)
    self.name = name
    self.signature = signature
    self.length = length
    self.block_size = block_size
    self.format = format
    self.reserve = reserve
  end

  def self.formats
    @@formats
  end

  def name=(name)
    @name = name.to_s
  end

  def signature=(signature)
    @signature = signature.to_s
  end

  def length=(length)
    @length = length.to_f
  end

  def block_size=(block_size)
    @block_size = block_size.to_f
  end

  def reserve=(reserve)
    @reserve = reserve.to_f
  end

  def format=(format)
    format = @@formats[:UNKNOWN] unless @@formats.has_value?(format)
    @format = format
  end
end

class Block
  @@types = {UNKNOWN: :UNKNOWN, NORMAL: :NORMAL, RESERVE: :RESERVE}

  attr_reader :magazine, :start, :finish, :used, :type

  def initialize(magazine, start, finish, used, type = @@types[:NORMAL])
    self.magazine = magazine
    self.start = start
    self.finish = finish
    self.used = used
    self.type = type
  end

  def self.types
    @@types
  end

  def magazine=(magazine)
    @magazine = magazine
  end

  def start=(start)
    start = @finish if @finish && start > @finish
    @start = start.to_f
  end

  def finish=(finish)
    finish = @start if @start && finish < @start
    @finish = finish.to_f
  end

  def max_usage
    @finish - @start
  end

  def used=(used)
    used = self.max_usage if used > self.max_usage
    @used = used.to_f
  end

  def type=(type)
    type = @@types[:UNKNOWN] unless @@types.has_value?(type)
    @type = type
  end
end


class ShelfRow
  # private, etc
  attr_reader :name, :segment_cnt, :segment_length, :level_cnt
  # Q: Do all segments have same length
  def initialize(name, segment_cnt, segment_length, level_cnt)
    self.name = name
    self.segment_cnt = segment_cnt
    self.segment_length = segment_length
    self.level_cnt = level_cnt
    self.init_map
  end

  def init_map
    @map = Array.new(@level_cnt){Array.new(@segment_cnt){[]}}
  end

  def row_length
    @segment_cnt*@segment_length
  end

  def name=(name)
    @name = name.to_s
  end

  def segment_cnt=(segment_cnt)
    @segment_cnt = segment_cnt.to_i
  end

  def segment_length=(segment_length)
    @segment_length = segment_length.to_f
  end

  def level_cnt=(level_cnt)
    @level_cnt = level_cnt.to_f
  end

  def load(magazines)
    row = 0
    segment = 0
    used = 0

    magazines.each do |m|
      block = @segment_length - m.block_size/2

      # whole segment used
      if used >= block
        segment += 1
        if segment == @segment_cnt
          # row_cnt
          row += 1
          segment = 0
        end
        used = 0
      end

      if block - used >= m.length
        @map[row][segment].push(Block.new(m, used, used + m.length, m.length, Block.types[:NORMAL]))
        used += m.length
      else
        placed = block - used
        @map[row][segment].push(Block.new(m, used, @segment_length, placed, Block.types[:NORMAL]))
        segment += 1
        if segment == @segment_cnt
          # row_cnt
          row += 1
          segment = 0
        end
        while (m.length - placed) > block do
          @map[row][segment].push(Block.new(m, 0, @segment_length, block, Block.types[:NORMAL]))
          placed += block
          segment += 1
          if segment == @segment_cnt
            # row_cnt
            row += 1
            segment = 0
          end
        end
        used = m.length - placed
        @map[row][segment].push(Block.new(m, 0, used, used, Block.types[:NORMAL]))
      end

      # whole segment used
      if used >= @segment_length
        segment += 1
        if segment == @segment_cnt
          # row_cnt
          row += 1
          segment = 0
        end
        used = 0
      end

      if @segment_length - used >= m.reserve
        if m.reserve > 0
          @map[row][segment].push(Block.new(m, used, used + m.reserve, m.reserve, Block.types[:RESERVE]))
          used += m.reserve
        end
      else
        reserved = @segment_length - used
        @map[row][segment].push(Block.new(m, used, @segment_length, reserved, Block.types[:RESERVE]))
        segment += 1
        if segment == @segment_cnt
          # row_cnt
          row += 1
          segment = 0
        end
        while (m.reserve - reserved) > @segment_length do
          @map[row][segment].push(Block.new(m, 0, @segment_length, @segment_length, Block.types[:RESERVE]))
          reserved += @segment_length
          segment += 1
          if segment == @segment_cnt
            # row_cnt
            row += 1
            segment = 0
          end
        end
        used = m.reserve - reserved
        @map[row][segment].push(Block.new(m, 0, used, used, Block.types[:RESERVE]))
      end
      @map.each do |r|
        r.each do |s|
          s.each { |e| p [e.magazine.name, e.type, e.start, e.finish, e.used] }
          p '--segment--'
        end
        p '--------------'
      end
    end
  end

end



m1 = Magazine.new('auto', '123', 145, 10, Magazine.formats[:NORMAL], 150)
m2 = Magazine.new('technika', '110', 350, 7, Magazine.formats[:NORMAL], 0)
m3 = Magazine.new('kolo', '223', 100, 7, Magazine.formats[:NORMAL], 35)

sr1 = ShelfRow.new(1, 5, 100, 3)

magazines1 = [m1,]
magazines2 = [m1, m2, m3]

p magazines1

sr1.load magazines2
