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
  validates :category, presence: true
  validates :newvalue, numericality: { greater_than: 0 }
  validates :message, length: { maximum: 29 }, format: { allow_blank: true, with: /\A[[:ascii:]]\z/, message: "only allows ASCII characters" }
  validates :action, inclusion: { in: [ "add", "subtract" ] }
  # validates :value_type, inclusion: { in: [ "literal", "percent" ] }

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
