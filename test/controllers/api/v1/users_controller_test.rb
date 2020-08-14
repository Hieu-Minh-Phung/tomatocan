require 'test_helper'
require 'json'

class Api::V1::UsersControllerTest < ActionController::TestCase

  test "user should not be updated if current_user does not exist" do
    patch :update, as: :json, params: { id: 1, user: { name: 'Reagan', email: 'nicetomeetu@email.com', password: 'secret14', password_confirmation: 'secret14', permalink: 'reagan14' } }  
    assert_response 401
  end

  test "user should not be updated if user id is not current_user id" do
    sign_in users(:one)
    patch :update, as: :json, params: { id: 3, user: { name: 'Reagan', email: 'nicetomeetu@email.com', password: 'secret14', password_confirmation: 'secret14', permalink: 'reagan14' } }
    assert_response 401
  end

  test "failed event update should return 422 and errors in response" do
    user_test = users(:one)
    sign_in user_test
    patch :update, as: :json, params: { id: user_test.id, user: { name: nil, email: nil, password: nil, password_confirmation: nil, permalink: nil} }
    assert_response 422
    json_response = JSON.parse(response.body)
    assert_not_nil json_response['errors'] 
  end

  # cant check full access because no current_password params, need to add devise_parameter_sanitizer.permit(:account_update, keys: [:current_password])
  test "successful event update with less access" do
    user_test = users(:one)
    sign_in user_test
    patch :update, as: :json, params: { id: user_test.id, user: { name: 'Reagan'}}
    json_response = JSON.parse(response.body)
    assert_equal false, json_response['privileged']
    assert_equal 'Reagan', json_response['name'] 
  end
end