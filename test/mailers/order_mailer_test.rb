require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "confirmation" do
    order = orders(:one)
    order.regenerate_confirmation_token
    mail = OrderMailer.confirmation(order)

    assert_equal "Order confirmation ##{order.confirmation_token}", mail.subject
    assert_equal [ order.email ], mail.to
    assert_equal [ "orders@example.com" ], mail.from
    assert_match order.confirmation_token, mail.body.encoded
    assert_match order.line_items.first.product.name, mail.body.encoded
  end
end
