require 'lib/header-inserter/project'

class ProjectFile
  include Comparable
  attr_reader :project, :path
  
  def initialize project, path
    if project.nil?
      @project = Project.new "/"
    else
      @project = project
    end
    @path = path
  end
  
  def <=> other
    absolute_path <=> other.absolute_path
  end
  
  def absolute_path
    absolute = @project.path
    absolute += File::SEPARATOR if @project.path != "/"
    absolute + @path
  end
  
  def retrieve_original_header
    file = File.new absolute_path, "r"
    header = ""
    while (line = file.readline) and not(/\s*(?:package|class|import)\s*/.match line)
      header += line
    end
    header
  rescue Errno::ENOENT
    return nil
  end
end