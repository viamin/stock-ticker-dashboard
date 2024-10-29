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
class Stock < ApplicationRecord
  extend FriendlyId
  friendly_id :ticker, use: :slugged

  has_many :prices, dependent: :destroy

  scope :with_prices, -> { includes(:prices) }

  broadcasts_refreshes

  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true

  def latest_price
    prices.order(:date).limit(1).last
  end

  def price_trend
    last_price, previous_price = prices.order(date: :desc).limit(2).pluck(:cents)
    last_price <=> previous_price
  end

  def price_trend_icon
    return "-" if price_trend.nil?

    price_trend.negative? ? "⏷" : "⏶"  # U+23F7 and U+23F6
  end
end
