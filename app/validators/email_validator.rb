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