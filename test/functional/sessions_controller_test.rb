require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures 'products', 'users'

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

  test 'POST to create with valid data' do
    post :create, email: @ringo.email, password: '123'

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type

    assert_equal @ringo.id, session[:user_id]
  end

  test 'POST to create with unexistent email' do
    post :create, email: 'unexistent@example.com', password: '123'

    assert_response :success

    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_equal 'Invalid password or username', flash[:error]

    assert_form session_path, method: :post
  end

  test 'POST to create with invalid password'  do
    post :create, email: @ringo.email, password: 'INVALID'

    assert_response :success

    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_equal 'Invalid password or username', flash[:error]

    assert_nil session[:user_id], 'User logged in with wrong password'
  end

  test 'DELETE to destroy' do
    delete :destroy

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type

    assert_nil session[:user_id], 'User not logged out properly'
  end

  test 'asssociate session order with user on login' do
    @order = Order.create line_items_attributes: [
        { product_id: @nikon.id, quantity: 6 }
      ]

    session[:order_id] = @order.id

    post :create, email: @ringo.email, password: '123'

    assert_equal @ringo, @order.reload.user
  end
end
