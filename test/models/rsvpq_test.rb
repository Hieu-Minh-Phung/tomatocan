require 'test_helper'

class RsvpqTest < ActiveSupport::TestCase

  setup do
    @rsvpqT = Rsvpq.find(1)
  end

  test "event_id_must_not_be_empty" do
    @rsvpqT.event_id = nil
    assert_not @rsvpqT.valid?, "Empty event_id accepted"

    @rsvpqT.event_id = rsvpqs(:valid_rsvpq_two).event_id
    assert @rsvpqT.valid?, "Valid event_id not accepted"
  end

  test 'test_email' do
    #Email format test
    email_entry =  'this@@@@email@@@@.wontwork.'
    @rsvpqT.email = email_entry
    assert_not @rsvpqT.valid?, "Invalid email format accepted"
    #Email presence test
    @rsvpqT.email = "thisIsmyEmail@gmail.com"
    @rsvpqT.user_id = nil
    assert @rsvpqT.valid?, "email present when user_id absent should be valid"
  end

  test 'test_email_length over 254 chars' do
    @rsvpqT.email = "a" * 245 + "@example.com"
    assert_not @rsvpqT.valid?, "email is over 254 characters"
  end

  test 'test_email_length equals 254 chars' do
    @rsvpqT.email = "a" * 242 + "@example.com"
    assert @rsvpqT.valid?, "email at the limit should be valid"
  end

  test 'test_email_case_sensitive' do
    mixed_case_email = "AcB@ExAmpLe.cOm"
    @rsvpqT.email = mixed_case_email
    @rsvpqT.save
    assert_equal mixed_case_email.downcase, @rsvpqT.reload.email
  end
end