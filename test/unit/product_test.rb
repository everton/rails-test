require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  fixtures 'line_items', 'products'

  test 'basic Product creation' do
    assert_difference 'Product.count' do
      @product = Product.create name: 'Test product', price: 500,
        description: 'Lorem ipsum dolor sit amet',
        image: fixture_file_upload('images/hal9000.jpg')
    end

    assert_equal '300x225>', @product.image.styles[:medium].geometry
    assert_equal '100x75>',  @product.image.styles[:thumb ].geometry
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

  test 'destroy existing Product marking it as destroyed' do
    # The unescoped count verifies for paranoid model
    assert_no_difference 'Product.unscoped.count' do
      assert_difference 'Product.count', -1 do
        @nikon.destroy
      end
    end

    assert_raises ActiveRecord::RecordNotFound do
      Product.find @nikon.id
    end

    Product.with_deleted do
      assert_equal @nikon, Product.find(@nikon.id)
    end
  end

  test 'line_item relation' do
    assert_equal [@li_john_nikon, @li_paul_nikon].sort,
      @nikon.line_items.sort
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

  test 'should avoid products without image' do
    assert_bad_value Product, :image, nil, :blank
  end
end
