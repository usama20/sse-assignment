class BlogsApiResponseJob < ApplicationJob
  queue_as :default

  def perform(blog_ids)
    api_responses = []
    
    blog_ids.each do |blog_id|        
      # Simulate some network latency
      sleep(0.1)

     # AppendingHash for bulk insert response
      api_responses << {
        api_response_id: "blog-#{SecureRandom.hex}-#{blog_id}",
        api_status: ApiResponse.api_statuses.keys.sample,
        blog_id: blog_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    # Bulk Insert
    ApiResponse.insert_all(api_responses) unless api_responses.empty?
  end

end
