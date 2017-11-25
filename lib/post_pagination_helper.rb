# frozen_string_literal: true

module PostPaginationHelper
  def page_from_params(params)
    if params[:next]
      params[:next_value]
    elsif params[:previous]
      params[:previous_value]
    else
      params[:page] || 1
    end
  end
end
