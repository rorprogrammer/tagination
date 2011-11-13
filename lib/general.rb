##
# This file was created 22-10-2008
# @author $Author: Eugen Mueller $
# @version $Revision: 0.2 $
module General

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
  
  #Tag class that represent a tag Object
  class Tag < ParamInitializer
    #label of a tag
    attr_accessor :label
    #count of a label
    attr_accessor :count
  end
  
  #Resource class represents a resource Object
  class Resource < ParamInitializer
    # resource id identify the resource
    attr_accessor :resource_id
    # title of the specific resource
    attr_accessor :title
    # resource upload date
    attr_accessor :upload_date
    # a hash list of tags from the resource 
    attr_accessor :tags
    # description of the resource
    attr_accessor :description
    # result view thumbnail url of the resource
    attr_accessor :list_thumb_url
    # javascript preview thumbnail url
    attr_accessor :js_thumb_url
    # preview thumbnail_url
    attr_accessor :preview_thumb_url
    # the direct web_url to the resource
    attr_accessor :link_url
  end
  
  #Taglist contains a list of Tags
  class TagList < ParamInitializer
    # taglist belongs to a resource type like video, photo, bookmarks, musik aso.
    attr_accessor :resource_type
    # a hash list of tags in differece to a tag object
    attr_accessor :tags
    
    # method to add a tag to a taglist independent from the tag object
    # or a string object
    def add(tag)
        if (tags.has_key?(tag))
          tags[tag] += 1
        else
          tags[tag] = 1
        end
    end
    
    # merge taglist with each other if the resource type is the same
    def merge_list(list)
       list.tags.each{|label, count| 
          if(self.tags.has_key?(label))
            self.tags[label] += count
          else
            self.tags[label] = count
          end
        }
     end
  end
  
  # Resourcelist class
  class ResourceList < ParamInitializer
    # the  taggingsystem
    attr_accessor :tagging_system
    # the reourcelist with an amount of resource objects
    attr_accessor :resources
    # the actual page of the view
    attr_accessor :actual_page
    # the total_pages
    attr_accessor :total_pages
    # count of the total results
    attr_accessor :total_results
  end
  
  # the Taggingsystem class is the base class for each system 
  # which is requested across the search process
  class TaggingSystem < ParamInitializer
    #variables of a tagging system
    attr_accessor :name, :nick, :url, :media_type, :service_uri, :api_key
    
    def initialize(name, nick, url, media_type)
      self.name = name 
      self.nick = nick
      self.url = url
      self.media_type = media_type
    end
    
    def search(tags, params)
    end
    
    private 
    def human_time(time)
    end
    
  end
end