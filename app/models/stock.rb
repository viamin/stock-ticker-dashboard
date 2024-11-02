# == Schema Information
#
# Table name: stocks
#
#  id          :integer          not null, primary key
#  category    :string
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

  def to_s(display: :web)
    "#{ticker} #{latest_price}#{price_trend_icon(display: display)}"
  end

  def latest_price
    prices.order(:date).limit(1).last
  end

  def price_trend
    last_price, previous_price = prices.order(date: :desc).limit(2).pluck(:cents)
    last_price <=> previous_price
  end

  def price_trend_icon(display: :web)
    return "-" if price_trend.nil?
    if display == :web
      price_trend.negative? ? "⏷" : "⏶" # U+23F7 and U+23F6
    else # for Arduino
      price_trend.negative? ? "}" : "{" # overriden in the ticker and sign templates
    end
  end

  class << self
    def categories
      {
        "Wet" => "WET",
        "Miscellaneous" => "MISC",
        "Shiny" => "SHINY",
        "False Hope" => "FALSE HOPE",
        "Glass" => "GLASS",
        "Carbon Dated" => "CARBON DATED",
        "Paper" => "PAPER",
        "Unicorn Tears" => "UNICORN TEARS",
        "Mushrooms" => "MUSHROOMS",
        "Landfill Futures" => "LANDFILL FUTURES",
        "Future Dreams" => "FUTURE DREAMS",
        "Organic" => "ORGANIC"
      }
    end

    def full_ticker(display: :web)
      all.map { |s| s.to_s(display: display) }.join("  ")
    end
  end
end
