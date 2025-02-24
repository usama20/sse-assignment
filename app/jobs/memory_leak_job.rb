class MemoryLeakJob < ApplicationJob
  queue_as :default

  def perform(batch_size = 1000)
    # Array for storing valid blog ids
    valid_blogs_ids = []
    
    # instead of Blog.all, we use Blog.find_in_batches to load records in batches to avoid memory overflow
    Blog.find_in_batches(batch_size: 1000) do |batch|
      batch.each do |blog|
        if blog_valid?(blog)
          valid_blogs_ids << blog.id           
        else  
          Rails.logger.info "Invalid blog: #{blog.id}"
        end
      end
      # Enqueue the job with valid blog ids if the array reaches the batch size this job will fetch responses for each blog and save it
      BlogsApiResponseJob.perform_later(valid_blogs_ids)
      valid_blogs_ids.clear
    end

  end

  private

  def blog_valid?(blog)
    blog.title.present? && blog.body.present?
  end

end