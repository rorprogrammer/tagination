require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class Delicious < General::TaggingSystem
  
  def initialize
    super("DELICIOUS", "delicious", "http://delicious.com/", "bookmark")
    self.service_uri = "http://feeds.delicious.com/v2/rss/tag/"
  end
  
  def get_shrink_url_for(url, size)
    #return %{http://www.shrinktheweb.com/xino.php?embed=1&u=2fc3c&STWAccessKeyId=4497733af252daa&Size=#{size}&Url=#{url}}
    return %{http://www.websitescreenshots.net/tumb.php?url=#{url}&size=small}
  end
  
  def human_time(time)
    return time.to_time.strftime("%d. %B %Y")
  end
  
  def search(tags, params)
    begin
      tags_to_escape = tags.strip.split
      tags_to_join = Array.new
      tags_to_escape.each do |tag|
        tags_to_join << CGI.escape(tag)
      end
      tags_to_search = tags_to_join.join('+')
      if params[:page].to_i > 12
        @page = 12
      else
        @page = params[:page].to_i
      end
      request_url = self.service_uri + "#{tags_to_search}?count=#{params[:per_page].to_i*@page}"
      content = ""
      open(request_url) do |f| content = f.read end
      rss = RSS::Parser.parse(content, false)
    rescue Exception => e
      puts "Error at Delicious! #{e.to_s}"
      rss = RSS::Rss.new
    else
      total_results = rss.items.size;
      total_pages = 12
      
      resource_list = General::ResourceList.new(:tagging_system => self,
                                                :resources => Array.new,
                                                :total_pages => total_pages,
                                                :total_results => total_results,
                                                :actual_page => @page.to_i)
      if total_results > 0
        start_index = total_results - 8
        for i in start_index..(total_results-1)
          post_id      = rss.items[i].comments.split('/').last
          post_title   = rss.items[i].title
          post_upload_date = human_time(rss.items[i].pubDate)
          post_tags = Array.new
          rss.items[i].categories.each do |cat|
            post_tags << cat.content
          end 
          post_resource_url = rss.items[i].link
          post_description  = rss.items[i].source
          
          resource = General::Resource.new(:resource_id => post_id,
                                  :title => post_title,
                                  :upload_date => post_upload_date,
                                  :tags => post_tags,
                                  :description => post_description,
                                  :list_thumb_url => get_shrink_url_for(post_resource_url, "sm"),
                                  :js_thumb_url => get_shrink_url_for(post_resource_url, "xlg"),
                                  :preview_thumb_url => post_resource_url,
                                  :link_url => post_resource_url)
          resource_list.resources.push(resource)
        end
      end
      return resource_list
    end
  end
end