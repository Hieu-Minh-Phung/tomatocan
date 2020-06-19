require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    #Basic data setup
    @eventT = Event.find(4)
    @eventT2 = Event.find(3)
    @invalidFormat = ["http", ".co", ".com", ".net", ".tv", ".uk", ".ly", ".me",
      ".biz", ".mobi", ".cn", "kickstarter", "barnesandnoble", "smashwords",
      "itunes", "amazon", "eventbrite", "rsvpify", "evite", "meetup"]
  end

  test "validate presence of usrid" do
    #usrid present
    @eventT.usrid = events(:four).usrid  #Ensuring usrid is present
    assert @eventT.save, "Event not saved with present usrid"

    #userid absent
    @eventT.usrid = nil
    assert_not @eventT.save, "Event saved with absent usrid"
  end

  test "validate presence of name" do
    #name present
    @eventT.name = events(:four).name  #Ensuring name is present
    assert @eventT.save, "Event not saved with present name"

    #name absent
    @eventT.name = nil
    assert_not @eventT.save, "Event saved with absent name"
  end

  test "validate presence of start_at" do
    #start_at present
    #Time with maximum time limit
    @eventT.end_at =   @eventT.start_at + 3.hour
    assert @eventT.save, "Event not saved with present start_at"
    #start_at absent
    @eventT.start_at = nil
    assert_not @eventT.save, "Event saved with absent start_at"
  end

  test "validate start_at cannot be in the past" do
    @eventT.start_at = events(:past_event)
    assert_not @eventT.save, "Saved event in the past"
  end

  test "validate 2 events cant have the same start time" do
    @eventT.start_at = events(:four).start_at
    @eventT.save!
    @eventT2.start_at = events(:four).start_at
    assert_not @eventT2.valid?, "Event saved with the same start time"
  end
  
  test "name without url" do
    evalFormat do |format|
      @eventT.name = events(:four).name + format
    end
  end

  test "desc without url" do
    evalFormat do |format|
      @eventT.desc = events(:four).desc + format
    end
  end

  test "address without url" do
    evalFormat do |format|
      @eventT.address = "Testing Address"+ format
    end
  end

  def evalFormat
    errorMsg = "Event saved with invalid format: "
    isInvalid = false
    @invalidFormat.each do |format|
      yield format
      isInvalid ||= @eventT.save
      if isInvalid then
        errorMsg.concat format
        break
      end
    end
    assert_not isInvalid, errorMsg
  end

  test "endat_greaterthan_startat" do
    #end_at greater than start_at
    @eventT.end_at = events(:four).end_at
    @eventT.start_at = @eventT.end_at - 2.hours
    assert @eventT.save, "Not accepting events with end_at > start_at"

    # Not validating end_at anymore
    # @eventT.start_at = events(:one).start_at
    # @eventT.end_at = @eventT.start_at - 2.hours
    # assert_not @eventT.save, "Accepting events with start_at > end_at"
  end

  test "rsvpqs association" do
    assert @eventT2.rsvpqs.count > 0, "event is not associated to rsvpqs"
  end

  test "users association" do
    assert @eventT2.users.count > 0, "rsvpqs is not associated to users"
  end
end
