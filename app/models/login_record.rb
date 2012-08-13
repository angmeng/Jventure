class LoginRecord < ActiveRecord::Base
  belongs_to :agent

  LOGIN = 1
  LOGOUT = 2

  def item_category
    if item_category_id == LoginRecord::LOGIN
      "<em style='color: green'>Login</em>"
    elsif item_category_id == LoginRecord::LOGOUT
      "<em style='color: red'>Logout</em>"
    else
      "Unknown"
    end
  end

end
