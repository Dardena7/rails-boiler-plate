require 'active_support/core_ext/hash/keys'

class FilesController < ApplicationController
  before_action :authorize!

  def create
    return render :json => {success: false, errors: ["Not authorized"]} unless is_admin?

    upload(params)
  end

  private

  def upload(params)
    files = params[:files] || []
    blob_ids = []

    files.each do |file|
      raise 'File is bigger than 2MB' if file.size > 2000000 #2MB
      raise 'File is not an image' if !is_valid_content_type(file.content_type)

      blob = ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: file.original_filename,
        content_type: file.content_type,
        metadata: { auth0_id: @token['sub'] }
      )
      blob_ids << blob.id
    end

    render json: { success: true, blob_ids: blob_ids }
  end

  private

  def is_valid_content_type(content_type)
    return content_type.start_with?('image/') || content_type == 'application/pdf'
  end

end
