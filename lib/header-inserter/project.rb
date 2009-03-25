require 'find'
require 'lib/header-inserter/project_file'

class Project
  include Comparable
  attr_reader :path
  
  def initialize path
    @path = File.expand_path(path)
  end
  
  def <=> other
    @path <=> other.path
  end
  
  def list file_pattern
    if file_pattern.is_a? Symbol
      file_pattern = /.*\.#{file_pattern.to_s}/
    end
    files = []
    Find.find @path do |entry|
      short_entry = entry.sub /^#{@path+File::SEPARATOR}/, ""
      if file_pattern.match short_entry
        files << ProjectFile.new(self, short_entry)
      end
    end
    files
  end
end