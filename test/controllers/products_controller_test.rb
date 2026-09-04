require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "index only shows active products" do
    inactive = Product.create!(name: "Discontinued Print", price_cents: 500, active: false)
    get products_url
    assert_response :success
    assert_no_match inactive.name, response.body
  end

  test "cannot view an inactive product directly" do
    inactive = Product.create!(name: "Discontinued Print", price_cents: 500, active: false)
    get product_url(inactive)
    assert_response :not_found
  end
end
