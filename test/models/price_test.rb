# == Schema Information
#
# Table name: prices
#
#  id         :integer          not null, primary key
#  cents      :integer
#  date       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stock_id   :integer          not null
#
# Indexes
#
#  index_prices_on_stock_id  (stock_id)
#
# Foreign Keys
#
#  stock_id  (stock_id => stocks.id)
#
require "test_helper"

class PriceTest < ActiveSupport::TestCase
  def setup
    Stock.destroy_all
    @stock = Stock.create!(
      name: "Apple Inc.",
      ticker: "AAPL"
    )

    @price = @stock.prices.create!(
      cents: 10050,  # $100.50
      date: Time.current
    )
  end

  test "should be valid with required attributes" do
    price = Price.new(stock: @stock, cents: 10000, date: Time.current)
    assert price.valid?
  end

  test "should belong to a stock" do
    @price.stock = nil
    assert_not @price.valid?
  end

  test "default scope orders by date descending" do
    old_price = @stock.prices.create!(date: 2.days.ago, cents: 9900)
    mid_price = @stock.prices.create!(date: 1.day.ago, cents: 10000)

    prices = @stock.prices.to_a
    assert_equal [ @price, mid_price, old_price ], prices
  end

  test "weekly scope returns prices from last 7 days" do
    old_price = @stock.prices.create!(date: 8.days.ago, cents: 9800)
    week_old_price = @stock.prices.create!(date: 6.days.ago, cents: 9900)

    weekly_prices = @stock.prices.weekly.to_a

    # Assert the correct number of prices
    assert_equal 2, weekly_prices.length

    # Assert correct prices are included/excluded
    assert_includes weekly_prices, @price
    assert_includes weekly_prices, week_old_price
    assert_not_includes weekly_prices, old_price

    # Assert ordering (should be newest first due to default scope)
    assert_equal [ @price, week_old_price ], weekly_prices
  end
end
