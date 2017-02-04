# frozen_string_literal: true
module RedirectExpectationHelper
  def it_redirects_to_with_notice(path, notice)
    it_redirects_to_internal(path)
    expect(flash[:notice]).to eq notice
    expect(flash[:error]).blank?
  end

  def it_redirects_to_with_error(path, error)
    it_redirects_to_internal(path)
    expect(flash[:error]).to eq error
    expect(flash[:notice]).blank?
  end

  def it_redirects_to_with_error_and_notice(path, error,notice)
    it_redirects_to_internal(path)
    expect(flash[:error]).to eq error
    expect(flash[:notice]).to eq notice
  end

  def it_redirects_to_internal(path)
    expect(response).to have_http_status :redirect
    expect(response).to redirect_to path
  end

  def it_redirects_to(path)
    it_redirects_to_internal(path)
    expect(flash[:notice]).blank?
    expect(flash[:error]).blank?
  end
end
