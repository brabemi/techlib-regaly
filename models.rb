require 'composite_primary_keys'

class Floor < ActiveRecord::Base
  has_many :shelf_rows
  validates :floor, presence: true, uniqueness: true
  validates :width, presence: true
  validates :height, presence: true
end

class Signature < ActiveRecord::Base
  validates :signature, presence: true, uniqueness: true
  has_many :years
end

class ShelfRow < ActiveRecord::Base
  self.table_name = 'shelf_rows'
  belongs_to :floor
  validates :name, presence: true, uniqueness: true
  validates :segment_lengths, presence: true
  validates :levels, presence: true
  validates :row_length, presence: true
  validates :row_width, presence: true
  validates :right_front_x, presence: true
  validates :right_front_y, presence: true
  validates :orientation, presence: true
  validates :floor_id, presence: true
end

class Year < ActiveRecord::Base
  self.primary_key = :signature_id, :year
  belongs_to :signature
  validates :year, presence: true, uniqueness: { scope: :signature_id }
  validates :volumes, presence: true
end
