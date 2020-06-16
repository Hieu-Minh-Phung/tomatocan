class Rsvpq < ApplicationRecord
  before_save {email.downcase!}
  belongs_to :user, :optional => true
  belongs_to :event
#  validates :user_id, presence: true
  validates :event_id, presence: true
  validates_format_of   :email, with: Devise.email_regexp, allow_blank: true
  validates :email, presence: {unless: :user_id? }, 
             length: {in: 3..254},
             uniqueness: {case_sensitive: false, scope: :event_id},
             allow_blank: true
end
