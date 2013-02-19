require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures 'users', 'orders'

  test 'basic User creation' do
    assert_difference 'User.count' do
      @user = User.create email: 'test_user@example.com',
        password: '123', password_confirmation: '123'
    end

    assert @user.authenticate('123'),
      'Password not encrypted properly'
  end

  test 'counting Users populated from fixtures' do
    assert_equal 4, User.count
  end

  test 'returning persisted Users' do
    user = User.find(@john.id)

    assert_kind_of User,  user
    assert_equal   @john, user
  end

  test 'update existing User' do
    assert_no_difference 'User.count' do
      @john.update_attributes email: 'new_test_user@example.com'
    end

    assert_equal 'new_test_user@example.com', @john.reload.email
  end

  test 'destroy existing User and associated Orders' do
    assert_difference 'User.count', -1 do
      assert_difference 'Order.count', -1 do
        @john.destroy
      end
    end

    assert_raises ActiveRecord::RecordNotFound do
      User.find @john.id
    end
  end

  test 'avoid blank email' do
    assert_bad_value User, :email, '   ', :blank
  end

  test 'avoid users with duplicated email' do
    assert_bad_value User, :email, @john.email, :taken
  end

  test 'avoid blank password' do
    assert_bad_value User, :password,              '   ', :blank
    assert_bad_value User, :password_confirmation, '   ', :blank
  end

  test 'ask for password confirmation' do
    user = User.new password_confirmation: '123'

    assert_bad_value user, :password, '321', :confirmation
  end

  test 'visibility of is_admin field' do
    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      User.create email: 'test_user@example.com',
        password: '123', password_confirmation: '123',
        is_admin: true
    end
  end

  test 'default user is not admin' do
    assert_difference 'User.count' do
      @user = User.create email: 'test_user@example.com',
        password: '123', password_confirmation: '123'
    end

    refute @user.is_admin?, 'is_admin was not protected'

    @user.is_admin = true
    @user.save!

    assert @user.reload.is_admin?
  end

  test 'orders relation' do
    assert_equal [@order_paul], @paul.orders
  end
end
