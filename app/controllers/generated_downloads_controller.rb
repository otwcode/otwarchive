# frozen_string_literal: true

class GeneratedDownloadsController < ApplicationController
  def show
    @generated_download = GeneratedDownload.find_by!(token: params[:token])

    if @generated_download.expired?
      @generated_download.file.purge_later if @generated_download.file.attached?
      head :gone
    elsif @generated_download.status == "ready" && @generated_download.file.attached?
      blob = @generated_download.file.blob
      redirect_to blob.service.url(
        blob.key,
        expires_in: ActiveStorage.service_urls_expire_in,
        filename: blob.filename,
        content_type: blob.content_type,
        disposition: :attachment
      ), allow_other_host: true
    elsif @generated_download.status == "failed"
      render :show, status: :unprocessable_content
    else
      render :show, status: :accepted
    end
  end
end
