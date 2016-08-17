class Thing < ApplicationRecord
  belongs_to :lookup
  has_many :measures
end
