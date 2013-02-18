require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  fixtures 'line_items', 'products'

  test 'basic LineItem creation' do
    assert_difference 'LineItem.count' do
      @li = LineItem.create product_id: @nikon.id, quantity: 2
    end

    assert_equal @nikon, @li.product

    old_price, @nikon.price = @nikon.price, 100
    @nikon.save!

    assert_equal old_price, @li.price
  end

  test 'protection of price' do
    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      LineItem.create product_id: @nikon.id, quantity: 1, price: 666
    end
  end

  test 'counting LineItems populated from fixtures' do
    assert_equal 3, LineItem.count
  end

  test 'returning persisted LineItem' do
    li = LineItem.find(@li_paul_nikon.id)

    assert_kind_of LineItem, li
    assert_equal @li_paul_nikon, li
  end

  test 'update existing LineItem' do
    old_price, @nikon.price = @nikon.price, 666
    @nikon.save!

    assert_no_difference 'LineItem.count' do
      @li_paul_nikon.update_attributes quantity: 3
    end

    assert_equal 3, @li_paul_nikon.quantity

    assert_equal old_price, @li_paul_nikon.price,
      'Original LineItem price was not used on update'
  end

  test 'destroy existing LineItem' do
    assert_difference 'LineItem.count', -1 do
      @li_paul_nikon.destroy
    end

    assert_raises ActiveRecord::RecordNotFound do
      LineItem.find @li_paul_nikon.id
    end
  end

  test 'avoid blank product' do
    assert_bad_value LineItem, :product_id, nil, :blank
  end

  test 'avoid blank quantity' do
    assert_bad_value LineItem, :quantity, nil, :blank
  end

  test 'avoid non positive quantity' do
    assert_bad_value LineItem, :quantity, 0,
      I18n.t('errors.messages.greater_than', count: 0)
    assert_bad_value LineItem, :quantity, -1,
      I18n.t('errors.messages.greater_than', count: 0)
  end

  test '#total' do
    @li = LineItem.create product_id: @nikon.id, quantity: 2
    assert_equal @nikon.price * 2, @li.total
  end

  test 'order relation'

  test 'product relation' do
    assert_equal @nikon, @li_john_nikon.product
  end
end
