class Smugmug < General::TaggingSystem
 
  # the initializer method for the smugmug class
  def initialize
    super("SMUGMUG", "smugmug", "http://www.smugmug.com", "photo")
    self.service_uri = "http://api.smugmug.com/hack/feed.mg?Type=keyword&format=rss"
  end
  
  def human_time(time)
    return time.to_time.strftime("%d, %B %Y")
  end
  
  def smugmugerize_sort(sort_by)
    return  'relevance' if sort_by.to_s == "Popular"
    return  'published' if sort_by.to_s == "Recent"
  end
  
  def search(tags, params)
    begin
      tags_to_escape = tags.strip.split
      tags_to_join = Array.new
       tags_to_escape.each do |tag|
        tags_to_join << CGI.escape(tag)
      end
      tags_to_search = tags_to_join.join("+")
      start_index = (params[:page].to_i*params[:per_page].to_i)-(params[:per_page].to_i-1)
      request_url = self.service_uri<<"&Data=#{tags_to_join.last}&ImageCount=#{params[:per_page]}&start=#{start_index}"

      url = URI.encode(request_url)
      data = Net::HTTP::Get.new(url)
      document = REXML::Document.new Net::HTTP.get(URI.parse(url))
    
    rescue Exception => e
      puts "Error at SmugMug! #{e.to_s}"
      document = REXML::Document.new
    else
      resources = Array.new
      total_results = (document.root.elements['channel'].elements.size - 9) * 20
      total_pages = (total_results.to_i - total_results.to_i % params[:per_page].to_i) / params[:per_page].to_i
     
      if total_results > 0
        document.root.elements['channel'].elements.each('item') do |photo|
          photo_id           = photo.elements['link'].text.split("#").last.to_s
          photo_title        = photo.elements['title'].text
          photo_upload_date  = human_time(photo.elements['pubDate'].text)
          if photo.elements['media:keywords']
            photo_tags         = photo.elements['media:keywords'].text.delete(',').split()
          else
            photo_tags         = tags_to_search.split('+')
          end
          photo_resource_url = photo.elements['link'].text
          photo_thumbnails   = Array.new 
          photo.elements['media:group'].elements.each('media:content') do |thumb|
            photo_thumbnails << thumb.attributes['url'].to_s
          end
          photo_description =  photo.elements['description'].text
          photo_link = photo.elements['link'].text.gsub(/#/, '/1/') << '/Large'
          resource = General::Resource.new(:resource_id => photo_id,
                                           :title => photo_title,
                                           :upload_date => photo_upload_date,
                                           :tags => photo_tags,
                                           :description => photo_description,
                                           :list_thumb_url => photo_thumbnails[0],
                                           :js_thumb_url => photo_thumbnails[2],
                                           :preview_thumb_url => photo_thumbnails[3],
                                           :link_url => photo_link)
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