class Location < ApplicationRecord
  has_many :labels, dependent: :destroy
  has_many :books, through: :labels

  validates :name, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :location_type, presence: true

  def full_address
    [address_line_1, address_line_2, city, state, zip_code].compact_blank.join(', ')
  end
end