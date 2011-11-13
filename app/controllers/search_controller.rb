class SearchController < ApplicationController
  
  # constant type initialization for default search params
  PAGE = 1
  PER_PAGE = 8
  SORT_BY = "relevance"
  DEFAULT_SYSTEMS = ["flickr", "youtube", "bibsonomy"]
  
  # method requests the given systems for resources tagged with the relevant tag
  # and list this results according to the systems
  def old_list
    if params[:tags].strip.empty? || params[:tags].nil?
      redirect_to root_path
    else
      @title = "Tagination Search"
      @available_systems = TYPES
      @media_to_search = params[:media_to_search].split('+')
      
      @request_params = Hash.new
      if session[:request_params].nil?
        @media_to_search.each do |media|
          @request_params[media] = {:page => PAGE, :per_page => PER_PAGE, :sort_by => SORT_BY}
        end
      else
        @request_params = session[:request_params]
      end
      @tags = params[:tags].strip.split('+')
      @cloud="general"
      @response_list = @@request.send_request(@tags.join(' '), @request_params)
      # set some user variables 
      session[:request_params] = @request_params
      session[:list_page] = nil
    end 
  end
  #the new list
  def list
    if params[:tags].strip.empty? || params[:tags].nil?
      redirect_to root_path
    else
      @title = "Tagination Search"
      # media to search checkbox data 
      @available_systems = TYPES
      @media_to_search = params[:media_to_search].split('+')
      @tags = params[:tags].strip.split('+')
      # tagingsystem to search generate from defaults or from params
      @systems_to_search = Array.new
      if params[:systems_to_search].nil?
        @systems_to_search << DEFAULT_SYSTEMS[0] if @media_to_search.include?('photo')
        @systems_to_search << DEFAULT_SYSTEMS[1] if @media_to_search.include?('video')
        @systems_to_search << DEFAULT_SYSTEMS[2] if @media_to_search.include?('bookmark')
      else
        @systems_to_search = params[:systems_to_search].split('+')
      end
      # create request params for request
      @request_params = Hash.new
      for system in @systems_to_search
        @request_params[system] = {:page => PAGE || params[:page], 
                                   :per_page => PER_PAGE || params[:per_page], 
                                   :sort_by => SORT_BY || params[:sort_by]} 
      end
      # send a request for needet systems and params
      @response_list = @@request.send_system_request(@tags.join(' '), @request_params)
      # safe the request params for future usage
      session[:request_params] = @request_params  
    end
  end
  
  # default search method provides verify tests for selected systems 
  # or set tags and redirect to the list action
  def search
    if !(params[:photo] or params[:video] or params[:bookmark]) or params[:tags].strip.empty?
      redirect_to root_path
    else
      @media_to_search = [params[:photo], params[:video], params[:bookmark]].compact
      @tags = params[:tags].strip.split(/[\+\,\ ]/).join('+')
      session[:request_params]=nil
      redirect_to search_path(:tags => @tags, :media_to_search => @media_to_search.join('+'))
    end
  end
  
  # list methods for only one system search 
  def list_photo
    if params[:tags].strip.empty?
      redirect_to root_path
    else
      @title = "Photo Search"
      @available_systems = ['photo']
      @request_params = session[:request_params]
      @systems_to_search = params[:systems_to_search].split('+')
      
      @request_params = Hash.new
      if @system_to_paginate
        @systems_to_search.each do |system|
          @request_params[system] = {:page => params["#{system}_page".intern], 
                                     :per_page => params["#{system}_per_page".intern], 
                                     :sort_by => params["#{system}_sort_by".intern]}
        end
      else
        @systems_to_search.each do |system|
          @request_params[system] = {:page => PAGE, :per_page => PER_PAGE, :sort_by => SORT_BY}
        end
      end
      @tags = params[:tags].split('+')
      @cloud='photo'
      @response_list = @@request.send_system_request(@tags.join(' '), @request_params)
      # set some user variables 
      session[:list_page] = nil
      render :template => 'search/list_system'
    end
  end
  
  
  def paginate_search
      @media_to_search = params[:media_to_search].split('+')
      @paginate_system = params[:paginate_system]
      @available_systems = TYPES
      
      @tags = params[:tags].delete(' ').split('+')
      
      @request_params = session[:request_params]
      @page = params[:page] 
      @per_page = params[:per_page]
      @sort_by = params[:sort_by]
      @request_params[@paginate_system] = {:page => @page, :per_page => @per_page, 
                                           :sort_by => @sort_by}
       # set some user variables 
      session[:list_page] = nil
      
      if request.xml_http_request?
         #params[@paginate_system] = @request_params.fetch(@paginate_system)
         @response_list = @@request.send_system_request(@tags.join(' '), @request_params)  
      else
         redirect_to search_path(:tags => @tags.join('+'), :media_to_search => @media_to_search.join('+'))
      end
      session[:request_params]
  end
end
