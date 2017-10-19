# require 'composite_primary_keys'

class Floor < ActiveRecord::Base
  has_many :shelf_rows
  validates :floor, presence: true, uniqueness: true
  validates :width, presence: true
  validates :height, presence: true
end

class Signature < ActiveRecord::Base
  validates :signature, presence: true, uniqueness: true
  validates :signature_prefix, presence: true
  validates :signature_number, presence: true
  validates :year_min, presence: true
  validates :year_max, presence: true
  validates :volumes_total, presence: true
  validates :volumes, presence: true
end

class ShelfRow < ActiveRecord::Base
  self.table_name = 'shelf_rows'
  belongs_to :floor
  validates :name, presence: true, uniqueness: { scope: :floor_id }
  validates :segment_lengths, presence: true
  validates :levels, presence: true
  validates :row_length, presence: true
  validates :row_width, presence: true
  validates :right_front_x, presence: true
  validates :right_front_y, presence: true
  validates :orientation, presence: true
  validates :floor_id, presence: true
end
