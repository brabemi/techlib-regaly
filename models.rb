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

class SimBooksValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:books] << 'Books have to be array' unless record.books.is_a?(Array)
  end
end

class SimShelfsValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:shelfs] << 'Shelfs have to be array' unless record.shelfs.is_a?(Array)
  end
end

class Simulation < ActiveRecord::Base
  include ActiveModel::Validations
  validates :name, presence: true, allow_blank: true
  validates :volume_width, presence: true
  # validates :shelfs, presence: true
  validates_with SimBooksValidator
  validates_with SimShelfsValidator
  # validates :books, presence: true
end
