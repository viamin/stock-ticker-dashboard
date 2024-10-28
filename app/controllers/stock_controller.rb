class StockController < ApplicationController
  def index
    @stocks = Stock.all.with_prices
  end

  def show
    @stocks = Stock.all.with_prices
    if params[:id].present?
      @stock = @stocks.find { |s| s.ticker == params[:id] } || @stocks.sample
    else
      @stock = @stocks.sample
    end
    @chart_data = @stock.prices.group_by_hour(:date).average(:cents).transform_values { |v| v / 100.0 }
  end
end
