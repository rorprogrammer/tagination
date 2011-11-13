class PreviewController < ApplicationController
  
  
  def show   
    @title = "Preview "+params[:preview_system].to_s.capitalize
    @preview_system = params[:preview_system]
    @systems_to_search = params[:preview_system]
    @request_params = Hash.new()
    if session[:preview_request_params].nil?
      @request_params[@preview_system] = {:page => params[:page], 
                                        :per_page => params[:per_page], 
                                        :sort_by => params[:sort_by]}
    else
      @request_params = session[:preview_request_params]
      session[:preview_request_params].clear
    end
    @tags = params[:tags].strip.split('+')
   
    @response_list = @@request.send_system_request(@tags.join(' '), @request_params)
    
    if params[:id] && params[:id] != "0"
      @preview_id = params[:id]
    else
      @preview_id = @response_list.resources_lists[@preview_system].resources.first.resource_id
    end
    if session[:list_page].nil?
      session[:list_page] = request.env['HTTP_REFERER']
    end
    if(@preview_system == 'flickr')
      @resource = @@request.getInfo(@preview_system, @preview_id)
    else #(params[:system] == 'video' || params[:system] == 'bookmark')
      @response_list.resources_lists[@preview_system].resources.each do |res|
        if(res.resource_id.to_s == @preview_id.to_s)
          @resource = res
        end
      end 
    end
  end
  
  def paginate_preview
    @preview_system = params[:preview_system]
    @systems_to_search = params[:preview_system].split('+')
    @tags = params[:tags].split('+')
    @request_params = Hash.new()
    @request_params[@preview_system] = {:page => params[:page], 
                                        :per_page => params[:per_page], 
                                        :sort_by => params[:sort_by]}
    session[:preview_requets_params] = @request_params
    
    if request.xml_http_request?
      @response_list = @@request.send_request(@tags.join(' '), @request_params)
      @resource = @response_list.resources_lists[@preview_system].resources.first
      
      if @preview_system == 'photo' 
        @resource =@@request.getInfo(@preview_system, @resource.resource_id)
      end
    else
      redirect_to preview_url(:id => '0', :preview_system => params[:preview_system],
                               :tags => params[:tags], :page => params[:page], :per_page => params[:per_page],
                               :sort_by => params[:sort_by])
    end
  end
  
  def ajax_show_resource
    @preview_id = params[:resource_id]
    @preview_system = params[:preview_system]
    
    if @preview_system == 'photo'
       @resource =@@request.getInfo(@preview_system, @preview_id)
     else
       @resource = General::Resource.new(:resource_id => @preview_id,
                                         :title => params[:title],
                                         :upload_date => params[:upload_date],
                                         :tags => params[:tags],
                                         :description => params[:description],
                                         :preview_thumb_url => params[:preview_thumb_url],
                                         :link_url => params[:link_url]) 
    end
  end
end
