require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email = Mail::Address.new(value)
    unless email.address =~ Devise.email_regexp
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  rescue Mail::Field::ParseError => e
    record.errors[attribute] << (options[:message] || "is not an email")
  end
end

class Rsvpq < ApplicationRecord
  belongs_to :user, :optional => true
  belongs_to :event
#  validates :user_id, presence: true
	validates :event_id, presence: true
	
	validates :email, presence: {unless: :user_id? }, 
             allow_blank: true, 
             length: {minimum: 3, maximum:254},
             email: true

end
