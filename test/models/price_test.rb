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
  fixtures :stocks, :prices

  def setup
    @stock = stocks(:one)
    @price = prices(:one)
  end

  test "should be valid with required attributes" do
    price = Price.new(stock: @stock, cents: 10000, date: Time.current)
    assert price.valid?
  end

  test "should belong to a stock" do
    @price.stock = nil
    assert_not @price.valid?
  end

  # test "default scope orders by date descending" do
  #   old_price = @stock.prices.create!(date: 2.days.ago, cents: 9900)
  #   mid_price = @stock.prices.create!(date: 1.day.ago, cents: 10000)

  #   dates = @stock.prices.pluck(:date)
  #   assert_equal [ @price.date, old_price.date, mid_price.date ], dates
  # end

  test "weekly scope returns prices from last 7 days" do
    old_price = @stock.prices.create!(date: 8.days.ago, cents: 9800)
    week_old_price = @stock.prices.create!(date: 6.days.ago, cents: 9900)

    # plucking dates to avoid id-related sqlite bug
    weekly_prices = @stock.prices.weekly.pluck(:date)

    # Assert the correct number of prices
    assert_equal 2, weekly_prices.length

    # Assert correct prices are included/excluded
    assert_includes weekly_prices, @price.date
    assert_includes weekly_prices, week_old_price.date
    assert_not_includes weekly_prices, old_price.date

    # Assert ordering (should be newest first due to default scope)
    assert_equal [ @price.date, week_old_price.date ], weekly_prices
  end
end
