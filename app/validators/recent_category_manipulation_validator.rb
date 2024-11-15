class RecentCategoryManipulationValidator < ActiveModel::Validator
  def validate(record)
    recent_manipulations = Manipulation.where(category: record.category, created_at: 10.minutes.ago..)

    if recent_manipulations.pluck(:action).include?(record.action)
      record.errors.add :base, "Category has already been manipulated fewer than 10 minutes ago"
    end
  end
end
