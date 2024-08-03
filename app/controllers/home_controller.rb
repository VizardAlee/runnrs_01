class HomeController < ApplicationController
  def index
    @products = Product.all.order("RANDOM()")
  end
end
