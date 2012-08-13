module AgentsHelper

  def generate_panel


    "<table cellpadding='0' cellspacing='0' class='tabbed' height='100%' width='100%'>
      <tr>
        <td class='sidebar' id='sidebar' valign='top'>

          <br />
          <div class='panel' id='recently'><h4>" +
             (link_to 'New', new_agent_path) + "<br />" +
             (link_to 'View All', agents_url) +
            "</h4></div>
        </td>

        <td class='main' id='main' valign='top'>
          <div style='float:left;margin-left:20px;width:80%;'>
            <p class='flash_message' id='tasks_flash' style='display:none;'>" +
	         flash.each do |name, msg|
	             content_tag :div, msg, :id => "flash_#{name}" 
	         end 
            + "</p>
        </div>" +

          if show_title? 
           "<div class='title' id='title'>" +  yield(:title) + "</div>" 

         end

         yield

        "</td>
      </tr>
    </table>"
             
  end
  
  def display_tree_view(agent, view)
    view ? ret = view : ret = "" 
    
    downlines = agent.licenses.all(:select => "id, fullname, code")   
    ret << "<li>" + agent.screen_name 
      unless downlines.size.zero?
        ret << "<ul>"
        downlines.each do |d|
          display_tree_view(d, ret)
        end
        ret << "</ul>"
      end
    ret << "</li>"
          
    ret

  end

 
  
end
