module ApplicationHelper
  def hbr(target = "")
    h.target.gsub(/(\r\n?)|(\n)/, "<br />").html_safe
  end
end
