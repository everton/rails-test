require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures 'orders', 'line_items', 'products', 'users'

  test 'basic Order creation' do
    assert_difference 'Order.count' do
      @order = Order.create user_id: @ringo.id,
        line_items_attributes: [
         { product_id: @nikon.id,         quantity: 2 },
         { product_id: @monster_beats.id, quantity: 2 }
        ]
    end

    assert_equal @ringo, @order.user
    assert_equal [@nikon, @monster_beats].sort,
      @order.line_items.map(&:product).sort
  end

  test 'counting LineItems populated from fixtures' do
    assert_equal 2, Order.count
  end

  test 'returning persisted Order' do
    order = Order.find(@order_paul.id)

    assert_kind_of Order, order
    assert_equal @order_paul, order
  end

  test 'update existing Order' do
    assert_no_difference 'Order.count' do
      @order_paul.update_attributes line_items_attributes: [
          { id: @li_paul_nikon.id,   quantity: 5 },
          { id: @li_paul_sony_hd.id, quantity: 0 }
        ]
    end

    products = @order_paul.reload.line_items.map(&:product)

    assert_includes products, @nikon
    assert_not_includes products, @sony_hd,
      'LineItem with quantity zero was not removed'

    assert_equal 5, @li_paul_nikon.reload.quantity
  end

  test 'destroy existing Order and LineItems' do
    assert_difference 'Order.count', -1 do
      assert_difference 'LineItem.count', -2 do
        @order_paul.destroy
      end
    end

    assert_raises ActiveRecord::RecordNotFound do
      Order.find @order_paul.id
    end
  end

  test 'avoid blank user' do
    assert_bad_value Order, :user_id, nil, :blank
  end

  test 'user relation' do
    assert_equal @paul, @order_paul.user
  end

  test 'line items relation' do
    assert_equal [@li_paul_nikon, @li_paul_sony_hd].sort,
      @order_paul.line_items.sort
  end

  test '#total' do
    expected = (@sony_hd.price * 2) + @nikon.price
    assert_equal expected, @order_paul.total
  end
end
