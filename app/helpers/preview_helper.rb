module PreviewHelper
  def create_preview_navigation_links(actual_page, total_pages, system, sort_by)
    links = ""
    if total_pages.to_i > 7
      if actual_page > 1
        links << create_preview_nav_link("<<", 1, system, sort_by, false)
        links << create_preview_nav_link("<", actual_page.to_i - 1, system, sort_by, false)
        if actual_page > 4
          links << "..."
        end
      end
      # decide where the actual page is to display
      i=actual_page.to_i - 3 if actual_page.to_i > 3 && actual_page.to_i < total_pages.to_i - 2
      i=actual_page.to_i - 2 if actual_page.to_i == 3
      i=actual_page.to_i - 1 if actual_page.to_i == 2
      i=actual_page.to_i if actual_page.to_i == 1
      i=actual_page.to_i - 4 if actual_page.to_i == total_pages.to_i - 2
      i=actual_page.to_i - 5 if actual_page.to_i == total_pages.to_i - 1
      i=actual_page.to_i - 6 if actual_page.to_i == total_pages.to_i
      7.times do
            links << create_preview_nav_link(i, i, system, sort_by, i== actual_page.to_i)
          i += 1
      end
      if actual_page < total_pages
        if actual_page < total_pages -3
          links << "..."
        end
        if actual_page < total_pages.to_i
          links << create_preview_nav_link(">", actual_page + 1, system, sort_by, false)
          links << create_preview_nav_link(">>", total_pages, system, sort_by, false)
        end
      end
    else
      i = 1
      total_pages.to_i.times do
        links << create_preview_nav_link(i, i, system, sort_by, i == actual_page.to_i)
        i += 1
      end
    end
    links  
  end
  
  # method creates a tag with a navigation link like page number or navigation arrow
  def create_preview_nav_link(link_content, page, system, sort, current)
     if !current
    tag = "<span class=\"page_link\">"
     link = link_to_remote link_content.to_s, 
                           :url => paginate_preview_path(:id => "0", :tags => @tags.join('+'),
                                                :preview_system => @preview_system,
                                                :per_page => 8,
                                                :sort_by => sort,
                                                :page => page.to_s),
                           :html=> {:href => paginate_preview_path(:id => "0", :tags => @tags.join('+'), 
                                                :preview_system => system,
                                                :per_page => 8,
                                                :sort_by => sort,
                                                :page => page.to_s)}
    else                                                  
      tag = "<span class=\"page_link_current\">" 
      link = link_content.to_s
    end
    tag << link
    tag << "</span>"
    tag
  end
  
  def create_description(description)
    ret = ""
    attributes = {}
    attributes["id"] = "descriprion"
    text = strip_tags(description)
    ret << content_tag(:div, text, attributes)
  end
  
  def create_tag_list(tags)
    
   if(!tags.nil?) 
     taglist = tags
   else
     taglist=["#"]
   end
   content_tag(:div, taglist.join(" "))
  end
end
