class RevertPriceJob < ApplicationJob
  queue_as :default

  def perform(product)
    # Revert the product price to default after expiration
    if product.negotiation_expires_at <= Time.current
      product.update(negotiated_price: nil, negotiation_expires_at: nil)
    end
  end
end
