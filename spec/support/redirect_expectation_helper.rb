# frozen_string_literal: true
module RedirectExpectationHelper
  def it_redirects_to_with_notice(path, notice)
    it_redirects_to(path)
    expect(flash[:notice]).to eq notice
  end

  def it_redirects_to_with_caution(path, caution)
    it_redirects_to(path)
    expect(flash[:caution]).to eq caution
  end

  def it_redirects_to_with_error(path, error)
    it_redirects_to(path)
    expect(flash[:error]).to eq error
  end

  def it_redirects_to(path)
    expect(response).to have_http_status :redirect
    expect(response).to redirect_to path
  end
end
