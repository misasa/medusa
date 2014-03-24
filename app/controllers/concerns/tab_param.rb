module TabParam
  def add_tab_param(url)
    return url if params[:tab].blank?
    work_url = url.sub(/tab=.*&/,"").sub(/\?tab=.*/,"")
    work_url + (work_url.include?("?") ? "&" : "?") + "tab=#{params[:tab]}"
  end
end
