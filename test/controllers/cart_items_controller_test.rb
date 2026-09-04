require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post cart_items_url, params: { product_id: products(:one).id }
    @cart_item = CartItem.last
  end

  test "adding a new product creates a cart item with quantity 1" do
    assert_equal 1, @cart_item.quantity
  end

  test "adding the same product again increments quantity instead of duplicating" do
    assert_no_difference("CartItem.count") do
      post cart_items_url, params: { product_id: products(:one).id }
    end
    assert_equal 2, @cart_item.reload.quantity
  end

  test "adding a different product creates a separate cart item" do
    assert_difference("CartItem.count", 1) do
      post cart_items_url, params: { product_id: products(:two).id }
    end
  end

  test "update with quantity_change increment increases quantity" do
    patch cart_item_url(@cart_item), params: { quantity_change: "increment" }
    assert_equal 2, @cart_item.reload.quantity
  end

  test "update with quantity_change decrement decreases quantity when above 1" do
    patch cart_item_url(@cart_item), params: { quantity_change: "increment" }
    patch cart_item_url(@cart_item), params: { quantity_change: "decrement" }
    assert_equal 1, @cart_item.reload.quantity
  end

  test "update with quantity_change decrement destroys the item when quantity is 1" do
    assert_difference("CartItem.count", -1) do
      patch cart_item_url(@cart_item), params: { quantity_change: "decrement" }
    end
  end

  test "destroy removes the cart item and redirects to the cart" do
    assert_difference("CartItem.count", -1) do
      delete cart_item_url(@cart_item)
    end
    assert_redirected_to cart_path
  end

  test "cannot update a cart item belonging to a different cart" do
    other_item = cart_items(:two)
    patch cart_item_url(other_item), params: { quantity_change: "increment" }
    assert_response :not_found
  end

  test "cannot destroy a cart item belonging to a different cart" do
    other_item = cart_items(:two)
    assert_no_difference("CartItem.count") do
      delete cart_item_url(other_item)
    end
    assert_response :not_found
  end
end
