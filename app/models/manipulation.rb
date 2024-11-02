# == Schema Information
#
# Table name: manipulations
#
#  id            :integer          not null, primary key
#  action        :string
#  category      :string
#  manipulator   :string
#  message       :text
#  newvalue      :string
#  racc_username :string
#  value_type    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Manipulation < ApplicationRecord
  validates :category, inclusion: { in: Stock.categories.values }
  validates :newvalue, presence: true, numericality: true
  validates :message, length: { maximum: 29 }
  validates :action, inclusion: { in: Manipulation.actions.values }
  validates :value_type, inclusion: { in: Manipulation.types.values }

  def to_json
    {
      type: "market",
      category: "category",
      category_type: category,
      action: action,
      value_type: "literal",
      newvalue: newvalue
  }.to_json
  end

  class << self
    def actions
      {
        "Add" => "add",
        "Subtract" => "subtract"
        # "Replace" => "replace"
      }
    end

    def types
      {
        "🗑️" => "literal",
        "%" => "percent"
      }
    end
  end
end
