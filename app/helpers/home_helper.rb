module HomeHelper

  def generate_flash
    flash[:notice] ?   content_tag(:div, content_tag(:p, flash[:notice]), :class => "strong", :style => "background-color:LightGreen;color:green;text-align:center;height:30px;padding-top:8px") : flash[:error] ?   content_tag(:div, content_tag(:p, flash[:error]), :class => "strong", :style => "background-color:pink;color:red;text-align:center;height:30px;padding-top:8px") : nil
  end
end
