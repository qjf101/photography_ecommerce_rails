class StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # TODO: Stripe retries failed webhook deliveries automatically (with
  # backoff, over several days), so brief outages self-heal on their own.
  # But if retries are ever fully exhausted (server down for days, a bug
  # that always errors here, etc.), an order can stay stuck at "pending"
  # forever even though the customer was actually charged. Add a periodic
  # reconciliation job (Solid Queue recurring job - config/recurring.yml)
  # that finds orders still "pending" past ~1hr, calls
  # Stripe::Checkout::Session.retrieve on them, and self-heals using the
  # same paid/failed logic below (extract it into a shared method so the
  # webhook and the reconciliation job both call the same code path).

  def create
    payload = request.body.read
    sig_header = request.headers["Stripe-Signature"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    case event.type
    when "checkout.session.completed"
      order = Order.find_by(stripe_checkout_session_id: event.data.object.id)

      if order
        shipping = event.data.object.collected_information.shipping_details
        order.update!(
          status: "paid",
          total_cents: event.data.object.amount_total,
          stripe_payment_intent_id: event.data.object.payment_intent,
          shipping_name: shipping&.name,
          shipping_address_line1: shipping&.address&.line1,
          shipping_address_line2: shipping&.address&.line2,
          shipping_city: shipping&.address&.city,
          shipping_state: shipping&.address&.state,
          shipping_postal_code: shipping&.address&.postal_code,
          shipping_country: shipping&.address&.country
        )
        order.cart&.destroy!
        OrderMailer.confirmation(order).deliver_later
      end
    when "checkout.session.expired"
      order = Order.find_by(stripe_checkout_session_id: event.data.object.id)

      order&.update!(status: "failed")
    when "charge.refunded"
      # Catches refunds issued directly from the Stripe dashboard (bypassing
      # admin refund action, which already sets this synchronously).
      # Only flips to "refunded" once the charge is FULLY refunded
      order = Order.find_by(stripe_payment_intent_id: event.data.object.payment_intent)

      order.update!(status: "refunded") if order && event.data.object.refunded
    end

    head :ok
  end
end
