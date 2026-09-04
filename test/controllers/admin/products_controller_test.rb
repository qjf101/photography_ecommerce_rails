require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "redirects guests away from the product list" do
    get admin_products_url
    assert_redirected_to root_path
  end

  test "redirects logged-in non-admins away too" do
    sign_in(users(:one), "password1")
    get admin_products_url
    assert_redirected_to root_path
  end

  test "allows an admin to view the product list" do
    sign_in_as_admin
    get admin_products_url
    assert_response :success
  end

  test "allows an admin to create a product with images" do
    sign_in_as_admin
    image = fixture_file_upload("test_image.png", "image/png")

    assert_difference("Product.count", 1) do
      post admin_products_url, params: { product: { name: "New Print", price_cents: 2500, images: [ image ] } }
    end

    product = Product.last
    assert_redirected_to edit_admin_product_path(product)
    assert product.images.attached?
  end

  test "allows an admin to update a product" do
    sign_in_as_admin
    patch admin_product_url(@product), params: { product: { name: "Updated Name" } }
    assert_redirected_to edit_admin_product_path(@product)
    assert_equal "Updated Name", @product.reload.name
  end

  test "allows an admin to disable a product" do
    sign_in_as_admin
    patch admin_product_url(@product), params: { product: { active: false } }
    assert_not @product.reload.active?
  end

  test "allows an admin to destroy a product with no line items" do
    sign_in_as_admin
    product = Product.create!(name: "Unpurchased Print", price_cents: 500)

    assert_difference("Product.count", -1) do
      delete admin_product_url(product)
    end
    assert_redirected_to admin_products_url
  end

  test "shows an error instead of crashing when destroying a product with line items" do
    sign_in_as_admin
    assert_no_difference("Product.count") do
      delete admin_product_url(@product)
    end
    assert_redirected_to admin_products_url
  end

  private

  def sign_in_as_admin
    sign_in(users(:admin), "adminpass1")
  end

  def sign_in(user, password)
    post login_url, params: { session: { email: user.email, password: password } }
  end
end
