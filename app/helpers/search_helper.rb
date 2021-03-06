module SearchHelper
   
   def current_search_page?(t)
    if( controller.action_name.to_s == t[:action].to_s)
      return true
    else
      return false
    end
  end
   
   def make_tab(t)
    # creates a navigation tab out of the given information.   
      tab = "<li"
      tab << ' id="current"' if current_search_page?(t[:options])
      tab << '>'
      tab << link_to(t[:name], t[:options])
      tab << '</li>'
      tab
  end
  
  def generate_tag_cloud_view(taglist, size, systems)
      @taglist = taglist
      #Set font size limits in pixels.
      @minFS = 16;
      @maxFS = 28;
      #Set font color limits between 0 and 255
      @minFC = 200;
      @maxFC = 255;
      # delete the search tags from the taglist
      @tags.each do |tag|
        @taglist.delete(tag)
      end
      # sort tags according to the count and slize an amount of them
      # and finaly sort according to a lexicographical sort
      @taglist = @taglist.sort {|a, b|  b[1] <=> a[1]}
      @taglist = @taglist.slice(0..(size-1))
      # for generation algorithm 
      @mincount = @taglist.last[1]
      @maxcount = @taglist.first[1]
      
      @taglist = @taglist.sort {|a, b| a[0] <=> b[0]}
      
      # generating font color and font size and the div to return
      cloud = ""
      for tag in @taglist
        count = tag[1]
        
        
        
         # calculate the weight of the current tag count
         # in relation to the upper and lower limits
         if (Math.log(@maxcount) - Math.log(@mincount) > 0)
            wg = (Math.log(count) - Math.log(@mincount)) / (Math.log(@maxcount) - Math.log(@mincount))
         else
            wg = (Math.log(count) - Math.log(@mincount))
         end
       
       
        
        #calculate font size
        fs = @minFS + ((@maxFS - @minFS)*wg).round
        #calculate font color
        fc = @minFC + ((@maxFC - @minFC)*wg).round
        
        cloud << " <span class=\"tag\">"
        link = link_to tag[0], {:action => controller.action_name,
                                :tags => (@tags + tag[0].to_a).join('+'),
                                :media_to_search => systems.join('+')},
                                :style => %{color: rgb(#{fc}, #{fc}, #{240});
                                            font-size: #{fs}px; 
                                            text-decoration: none;}
        cloud << link
        cloud << "</span> "
      end
      cloud
  end
  
  def create_link(tag, fc, fs, systems)
    link = link_to tag, {:action => controller.action_name,
                         :tags => (@tags + tag.to_a).join('+'),
                         :media_to_search => @media_to_search.join('+'),
                       
                         :sort_by => @sort_by},
                         :style => %{font-size: #{fs}px; 
                                     text-decoration: none;}
    link
  end
  # method creates the pagination links
  def create_navigation_links(actual_page, total_pages, system, sort_by)
    links = ""
    if total_pages.to_i > 7
      if actual_page > 1
        links << create_nav_link("<<", 1, system, sort_by, false)
        links << create_nav_link("<", actual_page.to_i - 1, system, sort_by, false)
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
            links << create_nav_link(i, i, system, sort_by, i== actual_page.to_i)
          i += 1
      end
      if actual_page < total_pages
        if actual_page < total_pages -3
          links << "..."
        end
        if actual_page < total_pages.to_i
          links << create_nav_link(">", actual_page + 1, system, sort_by, false)
          links << create_nav_link(">>", total_pages, system, sort_by, false)
        end
      end
    else
      i = 1
      total_pages.to_i.times do
        links << create_nav_link(i, i, system, sort_by, i == actual_page.to_i)
        i += 1
      end
    end
    links  
  end
  
  # method creates a tag with a navigation link like page number or navigation arrow
  def create_nav_link(link_content, page, system, sort, current)
     if !current
    tag = "<span class=\"page_link\">"
     link = link_to_remote link_content.to_s, 
                           :url => paginate_url(:tags => @tags.join('+'), 
                                                :media_to_search => @media_to_search.join('+'),
                                                :paginate_system => system,
                                                :per_page => 8,
                                                :sort_by => sort,
                                                :page => page.to_s),
                           :html=> {:href => paginate_path(:tags => @tags.join('+'), 
                                                :media_to_search => @media_to_search.join('+'),
                                                :paginate_system => system,
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
  
  def create_system_links(image, system, page, sort_by)
    return link_to_remote image_tag(image), 
                :url => paginate_url(:tags => @tags.join('+'), 
                                                :media_to_search => @media_to_search.join('+'),
                                                :paginate_system => system,
                                                :per_page => 8,
                                                :sort_by => sort_by,
                                                :page => page),
                           :html=> {:href => paginate_path(:tags => @tags.join('+'), 
                                                :media_to_search => @media_to_search.join('+'),
                                                :paginate_system => system,
                                                :per_page => 8,
                                                :sort_by => sort_by,
                                                :page => page)}
   end                      
end
