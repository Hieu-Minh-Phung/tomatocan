require 'test_helper'
require 'json'

class Api::V1::EventsControllerTest < ActionController::TestCase

# index
  test "index should return correct events" do
    @event1 = Event.create( user_id: 2, name: 'NiceEvent', start_at: Time.now, end_at: Time.now + 3.hours)
    @event2 = Event.create( user_id: 2, name: 'BadEvent', start_at: Time.now - 7.hours , end_at: Time.now - 7.hours)
    get :index, as: :json
    assert_response :success
    assert_includes @response.body, @event1.to_json
    refute_includes @response.body, @event2.to_json
  end

# end_at must be numerical, dont test with strings

# create
  test "event should not be created if current user does not exist" do
  	post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id: 1, name: "Phineas" } }
    assert_response 401
  end

  test "successful event creation should generate authentication token" do
    sign_in users(:one)
    post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id: 1, name: "Phineas" } } 
    assert_response :success # assert event creation  
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['success']
    assert_not_nil json_response['token']
  end

  test "failed event creation should return 422 and errors in response" do
    sign_in users(:one)
    post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id:nil, name:nil} } 
    assert_response 422  # unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['errors']
  end

  test "successful event creation should create event in database" do
    sign_in users(:one)
    assert_difference('Event.count', 1) do
      post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id: 1, name: "Phineas" } } 
    end
  end

  test "failed event creation should not create event in database" do
    assert_no_difference('Event.count') do
      post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id: 1, name: "Phineas" } }
    end

    sign_in users(:one)
    assert_no_difference('Event.count') do
      post :create, as: :json, params: { event: {start_at: "2022-02-11 11:02:57", end_at: :start_at, user_id:nil, name:nil} }
    end 
  end

# destroy
  test "event should not be deleted if current user does not exist" do
    event = Event.where("user_id = ?", 1).first
    delete :destroy, params: {id: event.id}
    assert_response 401    
  end

  test "event should not be deleted if event find by id does not exist" do
    sign_in users(:one)
    delete :destroy, params: {id: 9669}
    assert_response 422
  end

  test "event should not be deleted if event user_id is not current_user id" do
    sign_in users(:one)
    event = Event.where("user_id = ?", 6).first
    delete :destroy, params: {id: event.id}
    assert_response 422
  end

  test "successful event deletion should return success" do
    sign_in users(:one)
    event = Event.where("user_id = ?", 1).first
    delete :destroy, params: {id: event.id}
    assert_response :success
  end

  test "failed event deletion should not decrease count in database" do
    # current user does not exist
    assert_no_difference('Event.count') do
      event = Event.where("user_id = ?", 1).first
      delete :destroy, params: {id: event.id}
    end

    sign_in users(:one)
    # event find by id does not exist
    assert_no_difference('Event.count') do
      delete :destroy, params: {id: 9669}
    end

    # event user_id is not current_user id
    assert_no_difference('Event.count') do
      event = Event.where("user_id = ?", 6).first
      delete :destroy, params: {id: event.id}
    end
  end

  test "successful event decrease event count in database" do
    sign_in users(:one)
    assert_difference('Event.count', -1) do
      event = Event.where("user_id = ?", 1).first
      delete :destroy, params: {id: event.id}
    end
  end

  # update
  test "event should not be updated if event does not exist" do
    sign_in users(:one)
    patch :update, as: :json, params: { id: 8668, event: {start_at: "2022-02-11 11:02:57", name: "Phineas" } }
    assert_response 422 
  end

  test "event should not be updated if current_user does not exist" do
    patch :update, as: :json, params: { id: 1, event: {start_at: "2022-02-11 11:02:57", name: "Phineas" } }
    assert_response 401
  end

  test "event should not be updated if event user_id is not current_user id" do
    sign_in users(:one)
    patch :update, as: :json, params: { id: 6, event: {start_at: "2022-02-11 11:02:57", name: "Phineas" } }
    assert_response 401
  end

  test "successful event update should return correct info" do
    sign_in users(:one)
    patch :update, as: :json, params: { id: 1, event: {start_at: "2022-02-11 11:02:57", name: "Reagan", desc:"nicenice" } }
    assert_response :success
    event = Event.find_by_id(1)
    assert_equal "Reagan", event.name
    assert_equal "nicenice", event.desc
    assert_includes event.start_at.to_s, "2022-02-11 11:02:57"
  end

  test "failed event update should return 422 and errors in response" do
    sign_in users(:one)
    patch :update, as: :json, params: { id: 1, event: {start_at: nil } }
    assert_response 422
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['errors']
  end

end