module ApplicationHelper
  def sort_direction(column)
    return "asc" unless params[:sort] == column.to_s
    params[:direction] == "asc" ? "desc" : "asc"
  end

  def sort_indicator(column)
    return unless params[:sort] == column.to_s

    direction = params[:direction] == "asc" ? "↑" : "↓"
    tag.span direction, class: "text-gray-400 group-hover:text-gray-600"
  end
end
