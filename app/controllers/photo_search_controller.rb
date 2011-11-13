class PhotoSearchController < ApplicationController
  #constant type initialization of default params
  PAGE = 1
  PER_PAGE = 8
  SORT_BY = "relevance"
  
  def list
    if params[:tags].strip.empty? || params[:tags.nil?]
      redirect_to root_path
    else
      @title = "Photo Search"
      @available_systems = ["flickr", "smugmug"]
      @systems_to_search = ["photo"]
      @request_params = Hash.new
      if session[:photo_request_params].nil?
        @available_systems.each do |system|
          @request_params[system] = {:page => PAGE, :per_page => PER_PAGE, :sort_by => SORT_BY}
        end
      else
        @request_params = session[:photo_request_params]
      end
      @tags = params[:tags].delete(' ').split('+')
      @cloud = "photo"
      @response_list = @@request.send_system_request(@tags.join(' '), @request_params)
    end
    # set the request params to identify them later
    session[:photo_request_params] = @request_params 
  end
end
