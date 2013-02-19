require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures 'products', 'users'

  test 'recognition of new (signup)' do
    assert_routing({path: '/user/new', method: :get},
      {controller: 'users', action: 'new'})
  end

  test 'GET new as HTML logged in' do
    session[:user_id] = @john.id

    get :new

    assert_redirected_to '/'
  end

  test 'GET new as HTML unlogged' do
    get :new

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Signup'

    assert_form user_path, method: :post do
      assert_select 'input[type=?][name=?]', 'email',
        'user[email]'
      assert_select 'input[type=?][name=?]', 'password',
        'user[password]'
      assert_select 'input[type=?][name=?]', 'password',
        'user[password_confirmation]'
    end
  end

  test 'recognition of create' do
    assert_routing({path: '/user', method: :post},
      {controller: 'users', action: 'create'})
  end

  test 'POST to create as HTML logged in' do
    session[:user_id] = @john.id

    # users logged should not create new accounts
    assert_no_difference 'User.count' do
      post :create, user: {
        email: 'test_user@example.com',
        password: '123', password_confirmation: '123'
      }
    end

    assert_redirected_to '/'
  end

  test 'POST to create as HTML unlogged' do
    assert_difference 'User.count' do
      post :create, user: {
        email: 'test_user@example.com',
        password: '123', password_confirmation: '123'
      }
    end

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type
  end

  test 'asssociate session order with user at signup' do
    @order = Order.create line_items_attributes: [
        { product_id: @nikon.id, quantity: 6 }
      ]

    session[:order_id] = @order.id

    post :create, user: {
      email: 'test_user@example.com',
      password: '123', password_confirmation: '123'
    }

    @user = User.find_by_email! 'test_user@example.com'

    assert_equal @user, @order.reload.user
  end

  test 'POST invalid parameters to create as HTML' do
    assert_no_difference 'User.count' do
      post :create, user: {
        email: 'test_user@example.com',
        password: '   ', password_confirmation: '   '
      }
    end

    assert_response :success
    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_action_title 'Signup'

    assert_form user_path do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Password can't be blank")
      end
    end
  end

  test 'recognition of edit' do
    assert_routing({path: '/user/edit', method: :get},
      {controller: 'users', action: 'edit'})
  end

  test 'GET edit as HTML logged in' do
    session[:user_id] = @john.id

    get :edit

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit your account"

    assert_form user_path, method: :put do
      assert_select 'input[type=?][name=?][value=?]',
        'email', 'user[email]', @john.email
      assert_select 'input[type=?][name=?]',
        'password', 'user[password]'
      assert_select 'input[type=?][name=?]',
        'password', 'user[password_confirmation]'
    end
  end

  test 'GET edit as HTML unlogged' do
    get :edit

    assert_redirected_to '/session/new'
  end

  test 'recognition of update' do
    assert_routing({path: '/user', method: :put},
      {controller: 'users', action: 'update' })
  end

  test 'PUT to update as HTML logged in' do
    session[:user_id] = @john.id

    assert_no_difference 'User.count' do
      put(:update, user: {
            email: 'new_test_email@example.com'
          })
    end

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type

    assert_equal 'new_test_email@example.com', @john.reload.email
  end

  test 'PUT to update as HTML unlogged' do
    put(:update, user: {
          email: 'new_test_email@example.com'
        })

    assert_redirected_to '/session/new'
  end

  test 'PUT invalid parameters to update as HTML logged in' do
    session[:user_id] = @john.id

    assert_no_difference 'User.count' do
      put(:update, id: @john.to_param, user: {
            email: '   '
          })
    end

    assert_response :success
    assert_template :edit

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit your account"

    assert_form user_path, method: :put do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Email can't be blank")
      end
    end
  end

  test 'recognition of destroy' do
    assert_routing({path: '/user', method: :delete},
      {controller: 'users', action: 'destroy'})
  end

  test 'DELETE to destroy as HTML logged in' do
    session[:user_id] = @john.id

    delete :destroy

    assert_redirected_to '/'

    assert_raises ActiveRecord::RecordNotFound do
      User.find @john.id
    end
  end

  test 'DELETE to destroy as HTML unlogged' do
    delete :destroy

    assert_redirected_to '/session/new'
  end
end
