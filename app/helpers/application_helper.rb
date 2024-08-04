module ApplicationHelper
  def flash_class(type)
    case type
    when "alert"
      "red"   # or any other color for alerts
    when "notice"
      "green" # or any other color for notices
    else
      "blue"  # default color for other flash types
    end
  end
end
