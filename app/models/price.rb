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
class Price < ApplicationRecord
  belongs_to :stock

  default_scope { order(date: :desc).limit(100) }

  scope :weekly, -> { where(date: 7.days.ago..) }

  def dollars
    cents / 100.0
  end

  def to_s
    "$#{dollars}"
  end
end
