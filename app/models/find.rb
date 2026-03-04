class Find < ApplicationRecord
  belongs_to :book
  belongs_to :user
  belongs_to :label
end
