# represents the first site of Tagination
class TaginationController < ApplicationController
  
  def index
    @date = Time.now.strftime("%d. %B %Y")
    @available_systems = TYPES
    @title = "Tagination Search Plattform"
  end
  
  def about
    @title = "About Tagination"
  end

end
