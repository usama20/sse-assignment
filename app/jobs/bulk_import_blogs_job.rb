class BulkImportBlogsJob < ApplicationJob
  queue_as :default

  def perform(batch_size, file_path, user_id)
    # Do something later
    if File.exist?(file_path)
      # Call the service to process the file
      BulkImportBlogsService.new(batch_size, file_path, user_id).process

      # Delete the file after processing to save space
      File.delete(file_path) if File.exist?(file_path)
    else
      Rails.logger.error "File not found: #{file_path}"
    end
  end
end
