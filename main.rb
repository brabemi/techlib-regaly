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
  include Enumerable
  # private, etc
  attr_reader :name, :segment_cnt, :segment_sizes, :level_cnt
  # Q: Do all segments have same length
  def initialize(name, segment_sizes, level_cnt)
    self.name = name
    self.segment_cnt = segment_sizes.size
    self.segment_sizes = segment_sizes
    self.level_cnt = level_cnt
    self.init_map
  end

  def init_map
    @map = Array.new(@level_cnt) do
      @segment_sizes.collect { |width| {width: width, space: []} }
    end
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

  def segment_sizes=(segment_sizes)
    @segment_sizes = segment_sizes.collect { |e| e.to_f}
  end

  def level_cnt=(level_cnt)
    @level_cnt = level_cnt.to_f
  end

  def print
    p '----row----'
    @map.each do |r|
      # p '--segment--'
      r.each do |s|
        p s[:space].map { |e| [e.magazine.name, e.type, e.start, e.finish, e.used] }
        # p '--segment--'
      end
      p '----row----'
    end
  end

  def each
    return @map.flatten(1).each unless block_given?
    @map.flatten(1).each { |item| yield item }
  end
end

class Warehouse
  include Enumerable
  # private, etc
  attr_reader :name, :shelf_rows

  def initialize(name)
    self.name = name
    @shelf_rows = []
  end

  def name=(name)
    @name = name.to_s
  end

  def push(shelf_row)
    @shelf_rows.push(shelf_row)
  end

  def each
    return @shelf_rows.each unless block_given?
    @shelf_rows.each { |item| yield item }
  end

  def load(magazines)
    used = 0
    segments = @shelf_rows.collect_concat { |s| s.to_a } .each
    seg = segments.next # last segment check

    magazines.each do |m|
      block = seg[:width] - m.block_size/2

      # whole segment used
      if used >= block
        seg = segments.next # last segment check
        used = 0
      end

      if block - used >= m.length
        seg[:space].push(Block.new(m, used, used + m.length, m.length, Block.types[:NORMAL]))
        used += m.length
      else
        placed = block - used
        seg[:space].push(Block.new(m, used, seg[:width], placed, Block.types[:NORMAL]))
        seg = segments.next # last segment check
        block = seg[:width] - m.block_size/2
        while (m.length - placed) > block do
          seg[:space].push(Block.new(m, 0, seg[:width], block, Block.types[:NORMAL]))
          placed += block
          seg = segments.next # last segment check
          block = seg[:width] - m.block_size/2
        end
        used = m.length - placed
        seg[:space].push(Block.new(m, 0, used, used, Block.types[:NORMAL]))
      end

      # whole segment used
      if used >= seg[:width]
        seg = segments.next # last segment check
        used = 0
      end

      if seg[:width] - used >= m.reserve
        if m.reserve > 0
          seg[:space].push(Block.new(m, used, used + m.reserve, m.reserve, Block.types[:RESERVE]))
          used += m.reserve
        end
      else
        reserved = seg[:width] - used
        seg[:space].push(Block.new(m, used, seg[:width], reserved, Block.types[:RESERVE]))
        seg = segments.next # last segment check
        while (m.reserve - reserved) > seg[:width] do
          seg[:space].push(Block.new(m, 0, seg[:width], seg[:width], Block.types[:RESERVE]))
          reserved += seg[:width]
          seg = segments.next # last segment check
        end
        used = m.reserve - reserved
        seg[:space].push(Block.new(m, 0, used, used, Block.types[:RESERVE]))
      end
    end
  end
end

m1 = Magazine.new('auto', '123', 345, 10, Magazine.formats[:NORMAL], 150)
m2 = Magazine.new('technika', '110', 350, 7, Magazine.formats[:NORMAL], 0)
m3 = Magazine.new('kolo', '223', 500, 7, Magazine.formats[:NORMAL], 35)
m4 = Magazine.new('kolo-1', '224', 250, 10, Magazine.formats[:NORMAL], 50)
m5 = Magazine.new('kolo-2', '225', 330, 10, Magazine.formats[:NORMAL], 50)
m6 = Magazine.new('test', '226', 450, 10, Magazine.formats[:NORMAL], 50)
m7 = Magazine.new('computer', '227', 390, 10, Magazine.formats[:NORMAL], 50)

sr1 = ShelfRow.new('D22a', [100,100,120,120], 5)
sr2 = ShelfRow.new('D22b', [80,80,80,80,80], 5)

warehouse = Warehouse.new('sklad A')
warehouse.push(sr1)
warehouse.push(sr2)

magazines2 = [m1, m2, m3, m4, m5, m6, m7]

magazines2.sort_by! { |m| m.signature }

warehouse.load(magazines2)
warehouse.each { |sr| sr.print }
