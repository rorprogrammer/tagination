class Myvideo < General::TaggingSystem
  def initialize
    super("MYVIDEO", "myvideo", "http://www.myvideo.de/", "video")
    self.service_uri = "https://api.myvideo.de/api2_rest.php?"
    self.api_key = ""
    @website_id = ""
  end
  
  #time normalization method
  def human_time(time)
    @time = Time.at(time.to_i)
    return @time.strftime("%d. %B %Y")
  end
  
  def myvideorize_sort(sort_by)
    return "myvideo.videos.list_popular_by_tag" if sort_by.to_s == "relevance"
    return "myvideo.videos.list_by_tag" if sort_by.to_s == "recent"
  end
  
  def search(tags, params)
    begin
      tags_to_search = tags.strip.split.join("+")
      method = myvideorize_sort(params[:sort_by])
      request_url = %{#{self.service_uri}method=#{method}&dev_id=#{self.api_key}&website_id=#{@website_id}&per_page=#{params[:per_page]}&page=#{params[:page]}&tag=#{tags_to_search}}
      clnt = HTTPClient.new
      response_myvideo = clnt.get_content(request_url)
      response_myvideo.gsub!("&lt;", '<')
      response_myvideo.gsub!("&gt;", '>')
      document = REXML::Document.new response_myvideo
    rescue Exception => e
      puts "Fehler beim Myvideo request: #{e.to_s}"
      document = REXML::Document.new
    else
      resources = Array.new
      if document.root.has_elements?
        response = document.root.elements['myvideo']
        total_results = response.elements['resultCount'].text.to_i
        total_pages = total_results / params[:per_page].to_i
        total_pages += 1 if total_results % params[:per_page].to_i > 0
        if response.elements['movie_list'].has_elements?
          response.elements['movie_list'].elements.each('movie') do |movie|
            movie_id       = movie.elements['movie_id'].text
            movie_title    = movie.elements['movie_title'].text
            movie_added    = human_time(movie.elements['movie_added'].text)
            movie_tags     = movie_title.gsub(/[-+,()\{\}\[\]._<>\"\/]/, '').downcase.squeeze(" ").split
            t_doc = REXML::Document.new movie.elements['permathumblink'].to_s
            movie_thumb    = t_doc.root.elements['a'].elements['img'].attributes['src']
            movie_url      = movie.elements['movie_url'].text
            
            resource = General::Resource.new(:resource_id => movie_id,
                                             :title => movie_title,
                                             :upload_date => movie_added,
                                             :tags => movie_tags,
                                             :list_thumb_url => movie_thumb,
                                             :js_thumb_url => movie_thumb,
                                             :preview_thumb_url => movie_thumb,
                                             :link_url => movie_url)
            resources.push(resource)
          end
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
