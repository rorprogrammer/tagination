
# the youtube library class provides methods to search 
# youtube videos 
class Youtube  < General::TaggingSystem
  # the initializer method for the youtube class
  def initialize
    super("YOUTUBE", "youtube", "http://de.youtube.com/", "video")
    self.service_uri = "http://gdata.youtube.com/feeds/api/videos"
  end
  
  #conver the time string  in a tagination specific format 
  def human_time(time)
    return time.to_time.strftime("%d. %B %Y")
  end
    
  def youtuberize_sort(sort_by)
    return  'relevance' if sort_by.to_s == "relevance"
    return  'published' if sort_by.to_s == "recent"
  end
  # search for videos at youtube
  def search(tags, params)
    
    begin
     tags_to_search = tags.strip.split.join("/")
     start_index = (params[:page].to_i * params[:per_page].to_i)-(params[:per_page].to_i-1)
     order = youtuberize_sort(params[:sort_by])
     
     request_url = %{#{self.service_uri}/-/#{tags_to_search}/?orderby=#{order}&start-index=#{start_index}&max-results=#{params[:per_page]}}.strip
     url = URI.encode(request_url)
     # get the xml data from the system
     youtube_response = Net::HTTP.get(URI.parse(url))
     youtube_response.delete!("\"")
     document = REXML::Document.new youtube_response
    rescue Exception => e
      puts "Fehler beim Youtuberequest: #{e.to_s}"
      document = REXML::Document.new
    else
      # the response dependent attributes
      resources = Array.new
      total_results = document.root.elements['openSearch:totalResults'].text.to_i
      total_pages = total_results / params[:per_page].to_i
      
      if document.root.has_elements?
        document.root.elements.each('entry') do |video|
          video_id          = video.elements['id'].text.split("/").last
          video_title       = video.elements['title'].text
          video_upload_date = human_time(video.elements['published'].text) 
          video_tags        = video.elements['media:group'].elements['media:keywords'].text.delete(",").downcase.split
          thumbnails       = Array.new 
          video.elements['media:group'].elements.each('media:thumbnail') do |thumb|
            thumbnails << thumb.attributes['url']
          end
          video_list_thumbnail = thumbnails[rand(3)]
          video_js_thumbnail = thumbnails[3]
          video_description = video.elements['content'].text
          
          resource = General::Resource.new(:resource_id => video_id,
                                           :title => video_title,
                                           :upload_date => video_upload_date,
                                           :tags => video_tags,
                                           :description => video_description,
                                           :list_thumb_url => video_list_thumbnail,
                                           :js_thumb_url => video_js_thumbnail,
                                           :preview_thumb_url => "http://www.youtube.com/v/#{video_id}",
                                           :link_url => "http://de.youtube.com/watch?v=#{video_id}")
           resources.push(resource)
        end
        resource_list = General::ResourceList.new(:tagging_system => self,
                                         :resources => resources,
                                         :total_pages => total_pages,
                                         :total_results => total_results,
                                         :actual_page => params[:page].to_i)
        return resource_list
      else
        return nil
      end
    end
  end
end