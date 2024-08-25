class HomeController < ApplicationController
  def index
    # Randomize the products order and paginate
    @products = Product.order("RANDOM()").paginate(page: params[:page], per_page: 9)
    
    if current_user&.store_owner?
      @fulfilled_orders = fetch_orders_by_status('fulfilled')
      @income_data = @fulfilled_orders.group_by_day(:created_at).sum(:total)

      @chart_data = @income_data.map { |date, total| { date: date.to_s, income: total } }
    else
      @chart_data = []
    end

    puts "here is the debug for @chart_data: #{@chart_data.inspect}"
  end

  private

  def fetch_orders_by_status(status)
    return [] unless current_user&.store&.products

    product_ids = current_user.store.products.pluck(:id)
    Order.joins(shopping_cart: :line_items)
         .where(line_items: { product_id: product_ids })
         .where(status: status)
         .distinct
  end
end
