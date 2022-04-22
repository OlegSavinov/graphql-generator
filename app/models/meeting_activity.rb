class MeetingActivity < ApplicationRecord
  has_many :room_blockss, dependent: :destroy
  has_many :users, dependent: :destroy
  
end
