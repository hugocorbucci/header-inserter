require 'find'
require File.dirname(__FILE__) + '/project_file'
require File.dirname(__FILE__) + '/nil_version_control'
require File.dirname(__FILE__) + '/svn_version_control'

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
        version_control = obtain_version_control short_entry
        files << ProjectFile.new(self, short_entry, version_control)
      end
    end
    files
  end
  
  protected
  
  def obtain_version_control path
    entries_path = @path + "/#{File.dirname(path)}/.svn/entries"
    file_name = File.basename(path)
    entries = File.new entries_path, "r"
    contents = []
    entries.each{|line| contents << line}
    svn_path = contents[4].strip
    entry_for_file = contents.collect{|line| /^#{file_name}$/.match line }
    return SvnVersionControl.new(svn_path) unless entry_for_file.empty?
  rescue Errno::ENOENT
    NilVersionControl.new
  end
end