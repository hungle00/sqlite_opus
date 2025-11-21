# frozen_string_literal: true
# 
class SqliteDashboard::Uploader
  attr_reader :uploaded_file

  def initialize(uploaded_file)
  	@uploaded_file = uploaded_file
  end

  def save
  	output_file = SqliteDashboard.configuration.upload_file_path(uploaded_file.original_filename)
    
    if File.exist?(output_file)
      raise ArgumentError, "File with name '#{uploaded_file.original_filename}' already exists"
    end
    
    File.open(output_file, 'wb') do |file|
      file.write(uploaded_file.read)
    end
  end
end
