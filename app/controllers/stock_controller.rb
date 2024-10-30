class StockController < ApplicationController
  def index
    @stocks = Stock.all.with_prices
  end

  def show
    @stocks = Stock.all.with_prices
    @stock = @stocks.find { |s| s.ticker == params[:id] } || @stocks.sample
    @chart_data = @stock.prices.group_by_hour(:date).average(:cents).compact.transform_values { |v| v / 100.0 }
    chart_values = @chart_data.values
    padding = (chart_values.max - chart_values.min) * 0.1
    @chart_min = (chart_values.min - padding).floor
    @chart_max = (chart_values.max + padding).ceil
  end
end
