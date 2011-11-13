#require "flickr"
module Service
  
  # a generic record that initializes instance variables from the supplied hash
# mapping symbol names to their respective values.
  class ParamInitializer
    def initialize (params)
      if params
        params.each do |key, value| 
          instance_variable_set("@#{key}", value) if respond_to?(key.to_s)
        end
      end
    end
  end
  
  #class for deposit the ResponseList with a taglist or a tagcloud
  class ResponseList < ParamInitializer
    # a list of resources from different systems
    attr_accessor :resources_lists
    # tags that are used to generate te list
    attr_accessor :searched_tags
    # a hash of the tagclouds according to a type and a general one
    attr_accessor :tag_clouds
    # future tag clusters for significant domains
    attr_accessor :tag_clusters
  end
  
  # the main class of the service module which provides methods
  # for the controllers to search the tagging plattforms
  class ExternalRequest
    
    def send_system_request(tags, params)
      
      response_list = ResponseList.new(:resources_lists => Hash.new,
                                       :searched_tags => tags.downcase.split(),
                                       :tag_clouds => Hash.new,
                                       :tag_clusters => Hash.new)
      tag_cloud = General::TagList.new(:resource_type => 'general', :tags => Hash.new)                                 
       # the search thread accelarate the resquest time
      threads = Array.new
      # tag cloud for each media type
      @photo_tag_cloud    = General::TagList.new(:resource_type => 'photo', :tags => Hash.new)
      @video_tag_cloud    = General::TagList.new(:resource_type => 'video', :tags => Hash.new)
      @bookmark_tag_cloud = General::TagList.new(:resource_type => 'bookmark', :tags => Hash.new)
      # create a thread for each tagging system
      
      if params.has_key?('flickr')
        flickr = Flickr.new()
        threads << Thread.new{
            response_list.resources_lists['flickr'] = flickr.search(tags, params['flickr'])
            if !response_list.resources_lists['flickr'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['flickr'])
              @photo_tag_cloud.merge_list(tag_list)
            end
         }
      end
      if params.has_key?('smugmug')
         smugmug = Smugmug.new()
         threads << Thread.new{
            response_list.resources_lists['smugmug'] = smugmug.search(tags, params['smugmug'])
            if !response_list.resources_lists['smugmug'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['smugmug'])
              @photo_tag_cloud.merge_list(tag_list)
            end
          }
      end
      if params.has_key?('youtube')
        youtube = Youtube.new()
        threads << Thread.new{
            response_list.resources_lists['youtube'] = youtube.search(tags, params['youtube'])
            if !response_list.resources_lists['youtube'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['youtube'])
              @video_tag_cloud.merge_list(tag_list)
            end
          }
      end
      if params.has_key?('myvideo')
        myvideo = Myvideo.new()
        threads << Thread.new{
            response_list.resources_lists['myvideo'] = myvideo.search(tags, params['myvideo'])
            if !response_list.resources_lists['myvideo'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['myvideo'])
              @video_tag_cloud.merge_list(tag_list)
            end
          }
      end
      if params.has_key?('bibsonomy')
        bibsonomy = Bibsonomy.new()
        threads << Thread.new{
            response_list.resources_lists['bibsonomy'] = bibsonomy.search(tags, params['bibsonomy'])
            if !response_list.resources_lists['bibsonomy'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['bibsonomy'])
              @bookmark_tag_cloud.merge_list(tag_list)
            end
          }
      end
      if params.has_key?('delicious')
        delicious = Delicious.new()
        threads << Thread.new{
            response_list.resources_lists['delicious'] = delicious.search(tags, params['delicious'])
            if !response_list.resources_lists['delicious'].nil?
              tag_list = self.extract_tags(response_list.resources_lists['delicious'])
              @bookmark_tag_cloud.merge_list(tag_list)
            end
          }
      end
      # starts the threads
      threads.each { |thread| thread.join}
#      response_list.tag_clouds['photo'] = @photo_tag_cloud if systems.has_key?('flickr') || systems.has_key?('smugmug')
#      response_list.tag_clouds['video'] = @video_tag_cloud if systems.has_key?('youtube')
#      response_list.tag_clouds['bookmark'] = @bookmark_tag_cloud if systems.has_key?('bibsonomy')
      
      tag_cloud.merge_list(@photo_tag_cloud) if !@photo_tag_cloud.tags.empty?
      tag_cloud.merge_list(@video_tag_cloud) if !@video_tag_cloud.tags.empty?
      tag_cloud.merge_list(@bookmark_tag_cloud) if !@bookmark_tag_cloud.tags.empty?
      response_list.tag_clouds['general']  = tag_cloud
      
      return response_list
    end
    
    # get resource information from the tagging system
    def getInfo(system, resource_id)
      if system == 'flickr'
        flickr = Flickr.new()
        return flickr.getInfo(resource_id)
      end
      if system == "yuotube"
      end
    end
    # method to extract tags from a resourcelist and returns a taglist
    def extract_tags(list)
      tag_list = General::TagList.new(:resource_type => nil, :tags => Hash.new)
      list.resources.each do |res|
        res.tags.each do |tag|
          if(tag.downcase.to_s.length < 20)
            tag_list.add(tag.downcase.to_s)
          end
        end
      end
      return tag_list
    end 
  end
end