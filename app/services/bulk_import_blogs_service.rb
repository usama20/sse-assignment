require 'csv'

class BulkImportBlogsService

  def initialize(batch_size, file_path, user_id)
    @batch_size = batch_size      
    @file_path = file_path    
    @user_id = user_id        
  end

  def process
    blogs_data = []      
    invalid_blogs = []   
    # Read CSV file line by line instead of loading the whole file
    CSV.foreach(@file_path, headers: true, encoding: 'utf8') do |row|
      # Validate the row before adding it to the blogs_data array
      if check_blog_valid?(row)
        blogs_data << row.to_h.merge(
          user_id: @user_id, 
          created_at: Time.now, 
          updated_at: Time.now
        )
      else
        # Store invalid records for logging
        invalid_blogs << row.to_h  
      end
      # If batch size is reached, insert and log in bulk
      handle_bulk_insert_and_logging(blogs_data, invalid_blogs) if blogs_data.size >= @batch_size
    end
    # Insert and log remaining records after finishing CSV processing
    handle_bulk_insert_and_logging(blogs_data, invalid_blogs)
  end
  
  private

  # Checks if a blog record is valid
  def check_blog_valid?(row)
    blog = Blog.new(row.to_h.merge(user_id: @user_id))
    blog.valid?  
  end

  # Performs bulk insert of valid blog records
  def bulk_insert_blogs(blogs_data)
    ActiveRecord::Base.transaction do
      Blog.insert_all(blogs_data)  
    end
    blogs_data.clear  
  end

  # Logs invalid blog records into a CSV file
  def log_invalid_blogs(invalid_blogs)
    error_log_file = Rails.root.join('log', "invalid_blogs_#{Time.current.to_i}.csv")

    CSV.open(error_log_file, "a") do |csv|
      # Write headers only if the file is empty
      csv << ["Title", "Body", "User ID", "Errors"] if File.zero?(error_log_file)
      invalid_blogs.each { |record| csv << record }
    end
    invalid_blogs.clear  
  end

  # Handles both bulk inserting valid blogs and logging invalid ones
  def handle_bulk_insert_and_logging(blogs_data, invalid_blogs)
    bulk_insert_blogs(blogs_data) unless blogs_data.empty?    
    log_invalid_blogs(invalid_blogs) unless invalid_blogs.empty?
  end

end