module PostPaginationHelper
  def page_from_params(params)
    if params[:next_page]
      params[:next_page_value]
    elsif params[:previous_page]
      params[:previous_page_value]
    else
      params[:page] || 1
    end
  end
end
