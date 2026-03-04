class Label < ApplicationRecord
  belongs_to :book
  belongs_to :location
  belongs_to :user
end
