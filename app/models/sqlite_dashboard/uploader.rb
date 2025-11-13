# frozen_string_literal: true
# 
class SqliteDashboard::Uploader
  attr_reader :uploaded_file

  def initialize(uploaded_file)
  	@uploaded_file = uploaded_file
  end

  def save
  	output_file = Rails.root.join('storage', 'uploads', uploaded_file.original_filename)
    File.open(output_file, 'wb') do |file|
      file.write(uploaded_file.read)
    end
  end
end
