# the bibsonomy library class provides methods to search
# and retrieving the bibsonomy data
class Bibsonomy < General::TaggingSystem
  
  def initialize
    super("BIBSONOMY", "bibsonomy", "http://www.bibsonomy.org", "bookmark")
    self.service_uri = "http://www.bibsonomy.org/rss/"
  end
  
  def get_shrink_url_for(url, size)
    #return %{http://www.shrinktheweb.com/xino.php?embed=1&u=2fc3c&STWAccessKeyId=4497733af252daa&Size=#{size}&Url=#{url}}
    return %{http://www.websitescreenshots.net/tumb.php?url=#{url}&size=small}
  end
  
  def human_time(time)
    return time.to_time.strftime("%d. %B %Y")
  end
  
  def bibsonomize_sort(sort_by)
    return "order=folkrank&" if sort_by.to_s == "relevance"
    return "" if sort_by.to_s == "recent"
  end
  
  #search method to search the bipsonomy bookmarks
  def search(tags, params)
    
    begin
      tags_to_escape = tags.strip.split
      tags_to_join = Array.new
      tags_to_escape.each do |tag|
        tags_to_join << CGI.escape(tag)
      end
      tags_to_search = tags_to_join.join("+")
      start_index = (params[:page].to_i*params[:per_page].to_i)-(params[:per_page].to_i)
      
      #web search for  tags
      request_url = %{#{self.service_uri}tag/#{tags_to_search}?#{bibsonomize_sort(params[:sort_by])}bookmark.start=#{start_index}&bookmark.entriesPerPage=#{params[:per_page].to_i}}.strip
      url = URI.encode(request_url)
      # get the XML data as a string
      bibsonomy_request = Net::HTTP.get(URI.parse(url))
      # create a REXML object from the system request
      document = REXML::Document.new(bibsonomy_request)
    rescue Excetion => e
      puts "Fehler beim Bibsonomy-request: #{e.to_s}"
    else
      
      total_results = (document.root.elements.size.to_i - 1) * 20
      total_pages = (total_results.to_i / params[:per_page].to_i)
      
      resource_list = General::ResourceList.new(:tagging_system => self,
                                                :resources => Array.new,
                                                :total_pages => total_pages,
                                                :total_results => total_results,
                                                :actual_page => params[:page].to_i)
      
      if total_results > 0
        document.root.elements.each('item') do |post|
          post_id          = post.elements['link'].text.hash
          post_title       = post.elements['title'].text
          post_upload_date = human_time(post.elements['dc:date'].text)
          post_tags        = post.elements['dc:subject'].text
          post_tags   = post_tags.gsub(/[,._+-]/, ' ').strip
          post_tags        = post_tags.downcase.split
          post_resource_url = post.elements['link'].text
          post_description =  post.elements['description'].text
          
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