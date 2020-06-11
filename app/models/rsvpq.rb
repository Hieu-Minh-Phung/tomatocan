class Rsvpq < ApplicationRecord
  before_save {email.downcase!}
  belongs_to :user, :optional => true
  belongs_to :event
#  validates :user_id, presence: true
  validates :event_id, presence: true
  
  validates :email, presence: {unless: :user_id? }, 
             length: {in: 3..254},
             allow_blank: true, 
             uniqueness: {case_sensitive: false, scope: :event_id},
             email: true
end
