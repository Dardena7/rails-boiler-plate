module FilesUtils
  extend ActiveSupport::Concern

  def detach_files(object_files, file_ids)
    object_files.map do |file|
      if !file_ids.include?(file.id) 
        file.purge
      end
    end
  end

  def attach_files(object_files, file_ids)
    file_ids.map do |file_id|
      if !object_files.any? { |file| file.id == file_id}
        blob = ActiveStorage::Blob.find(file_id)
        object_files.attach(blob)
      end
    end
  end
end