# == Schema Information
#
# Table name: stocks
#
#  id          :integer          not null, primary key
#  description :text
#  name        :text
#  slug        :string
#  ticker      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_stocks_on_slug  (slug) UNIQUE
#
require "test_helper"

class StockTest < ActiveSupport::TestCase
  def setup
    @stock = Stock.create!(
      ticker: "AAPL",
      name: "Apple Inc."
    )
  end

  test "should be valid with required attributes" do
    stock = Stock.new(ticker: "MSFT", name: "Microsoft")
    assert stock.valid?
  end

  test "should require ticker" do
    @stock.ticker = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:ticker], "can't be blank"
  end

  test "should require unique ticker" do
    duplicate = Stock.new(ticker: "AAPL", name: "Apple Copy")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:ticker], "has already been taken"
  end

  test "should require name" do
    @stock.name = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:name], "can't be blank"
  end

  test "latest_price returns most recent price" do
    @stock.prices.create!(date: 1.day.ago, cents: 10000)
    new_price = @stock.prices.create!(date: Time.current, cents: 20000)

    assert_equal new_price, @stock.latest_price
  end

  test "price_trend returns -1 for downward trend" do
    @stock.prices.create!(date: 1.day.ago, cents: 20000)
    @stock.prices.create!(date: Time.current, cents: 10000)

    assert_equal(-1, @stock.price_trend)
  end

  test "price_trend returns 1 for upward trend" do
    @stock.prices.create!(date: 1.day.ago, cents: 10000)
    @stock.prices.create!(date: Time.current, cents: 20000)

    assert_equal 1, @stock.price_trend
  end

  test "price_trend_icon returns down arrow for negative trend" do
    @stock.prices.create!(date: 1.day.ago, cents: 20000)
    @stock.prices.create!(date: Time.current, cents: 10000)

    assert_equal "⏷", @stock.price_trend_icon
  end

  test "price_trend_icon returns up arrow for positive trend" do
    @stock.prices.create!(date: 1.day.ago, cents: 10000)
    @stock.prices.create!(date: Time.current, cents: 20000)

    assert_equal "⏶", @stock.price_trend_icon
  end
end
