# frozen_string_literal: true

class GeneratedDownloadsController < ApplicationController
  def show
    @generated_download = GeneratedDownload.find_by!(token: params[:token])

    if @generated_download.expired?
      @generated_download.file.purge_later if @generated_download.file.attached?
      head :gone
    elsif @generated_download.status == "ready" && @generated_download.file.attached?
      blob = @generated_download.file.blob
      redirect_to rails_storage_redirect_path(
        blob.signed_id,
        blob.filename.to_s,
        disposition: :attachment
      )
    elsif @generated_download.status == "failed"
      render :show, status: :unprocessable_content
    else
      render :show, status: :accepted
    end
  end
end
