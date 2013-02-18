require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures 'users'

  test 'recognition of new (login)' do
    assert_routing({path: '/session/new', method: :get},
      {controller: 'sessions', action: 'new'})
  end

  test 'GET new as HTML' do
    get :new

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Login'

    assert_form session_path, method: :post do
      assert_select 'input[type=?][name=?]', 'email', 'email'
      assert_select 'input[type=?][name=?]', 'password', 'password'
    end
  end
end
