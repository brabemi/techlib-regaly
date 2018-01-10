# require 'composite_primary_keys'

class FloorSection < ActiveRecord::Base
  has_many :shelf_rows
  validates :floor, presence: true
  validates :name, presence: true, uniqueness: true
end

class SigVolumesValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:volumes] << 'Volumes have to be hash' unless record.volumes.is_a?(Hash)
  end
end

class Signature < ActiveRecord::Base
  validates :signature, presence: true, uniqueness: true
  validates :signature_prefix, presence: true
  validates :signature_number, presence: true
  validates :year_min, presence: true
  validates :year_max, presence: true
  validates :volumes_total, presence: true
  validates :growth, presence: true
  validates_with SigVolumesValidator
end

class ShelfRow < ActiveRecord::Base
  self.table_name = 'shelf_rows'
  belongs_to :floor_section
  validates :name, presence: true, uniqueness: { scope: :floor_section_id }
  validates :segment_lengths, presence: true
  validates :levels, presence: true
  validates :row_length, presence: true
  validates :floor_section_id, presence: true
  validates :enabled, inclusion: [true, false]
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
  validates :description, presence: true, allow_blank: true
  validates :volume_width, presence: true
  validates_with SimBooksValidator
  validates_with SimShelfsValidator
end
