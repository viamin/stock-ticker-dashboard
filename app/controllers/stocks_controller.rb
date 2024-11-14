class StocksController < ApplicationController
  def index
    @stocks = Stock.active.with_prices

    if params[:sort].present?
      @stocks = sort_stocks(params[:sort], params[:direction])
    end
  end

  def show
    @stocks = Stock.active
    @stock = if params[:id].present?
      @stocks.friendly.find(params[:id])
    else
      @stocks.sample
    end

    @chart_data = @stock.prices.weekly.group_by_hour(:date).average(:cents).compact.transform_values { |v| v / 100.0 }
    chart_values = @chart_data.values
    padding = (chart_values.max - chart_values.min) * 0.1
    @chart_min = (chart_values.min - padding).floor
    @chart_max = (chart_values.max + padding).ceil

    @previous_stock = previous_stock(@stock)
    @next_stock = next_stock(@stock)
  end

  def search
    ticker = params[:ticker].upcase
    stock = Stock.find_by(ticker: ticker)
    if stock
      redirect_to stock_path(stock.ticker)
    else
      redirect_to root_path, alert: "Stock not found"
    end
  end

  private

  def previous_stock(current_stock)
    index = @stocks.index(current_stock)
    index && index > 0 ? @stocks[index - 1] : @stocks.last
  end

  def next_stock(current_stock)
    index = @stocks.index(current_stock)
    index && index < @stocks.size - 1 ? @stocks[index + 1] : @stocks.first
  end

  def sort_stocks(column, direction)
    direction = direction == "desc" ? "desc" : "asc"

    case column
    when "ticker", "name"
      # Database columns can use ActiveRecord sorting
      if direction == "desc"
        @stocks.order(column.to_sym => direction.to_sym)
      else
        @stocks.order(column.to_sym)
      end
    when "latest_price"
      # Manual sort for calculated latest_price
      sorted = @stocks.sort_by { |stock| stock.latest_price.cents }
      direction == "desc" ? sorted.reverse : sorted
    else
      @stocks
    end
  end
end
