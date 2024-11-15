class PositivePriceManipulationValidator < ActiveModel::Validator
  def validate(record)
    category_prices = Stock.active.where(category: record.category).map(&:latest_price).map(&:cents)
    if record.action == "subtract" && category_prices.min < (record.newvalue.to_i * 100)
      record.errors.add :base, "Amount would create a negative price - try a lower amount"
    end
  end
end
