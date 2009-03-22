require 'find'

class Project
  attr_reader :path
  
  def initialize path
    @path = File.expand_path(path)
  end
  
  def list file_pattern
    if file_pattern.is_a? Symbol
      file_pattern = /.*\.#{file_pattern.to_s}/
    end
    files = []
    Find.find @path do |entry|
      if file_pattern.match entry
        files << entry
      end
    end
    files.map{|entry| entry.sub /^#{@path+File::SEPARATOR}/, ""}
  end
end