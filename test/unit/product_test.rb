require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures 'products'

  test 'basic Product creation' do
    assert_difference 'Product.count' do
      Product.create name: 'Test product', price: 500,
        description: 'Lorem ipsum dolor sit amet'
    end
  end

  test 'counting Products populated from fixtures' do
    assert_equal 3, Product.count
  end

  test 'returning persisted Products' do
    product = Product.find(@nikon.id)

    assert_kind_of Product, product
    assert_equal   @nikon,  product
  end

  test 'update existing Product' do
    assert_no_difference 'Product.count' do
      @nikon.update_attributes name: 'New Test Name'
    end

    assert_equal 'New Test Name', @nikon.reload.name
  end

  test 'destroy existing Product' do
    assert_difference 'Product.count', -1 do
      @nikon.destroy
    end

    assert_raises ActiveRecord::RecordNotFound do
      Product.find @nikon.id
    end
  end

  test 'should avoid products with blank name' do
    assert_bad_value Product, :name, '   ', :blank
  end

  test 'should avoid products with duplicated names' do
    assert_bad_value Product, :name, @nikon.name, :taken
  end

  test 'should avoid products with blank price' do
    assert_bad_value Product, :price, nil, :blank
  end

  test 'should avoid products with blank description' do
    assert_bad_value Product, :description, '   ', :blank
  end
end