require File.dirname(__FILE__) + '/project'
require File.dirname(__FILE__) + '/nil_version_control'
require File.dirname(__FILE__) + '/svn_version_control'
require 'date'
require 'etc'

class ProjectFile
  include Comparable
  attr_reader :project, :path, :version_control
  
  def initialize project, path, version_control = NilVersionControl.new
    if project.nil?
      @project = Project.new "/"
    else
      @project = project
    end
    @path = path
    @version_control = version_control
  end
  
  def <=> other
    absolute_path <=> other.absolute_path
  end
  
  def absolute_path
    absolute = @project.path
    absolute += File::SEPARATOR if @project.path != "/"
    absolute + @path
  end
  
  def original_header
    file = File.new absolute_path, "r"
    header = ""
    while (line = file.readline) and not(/\s*(?:package|class|import)\s*/.match line)
      header += line
    end
    header
  rescue Errno::ENOENT
    return nil
  end
  
  def created_on
    return Date.today if modifications.empty?
    modifications[0].date
  end
  
  def contributors
    return [username.strip] if modifications.empty?
    modifications.map{ |mod| mod.author.strip }.uniq
  end
  
  def generate_header header, hooks
    generated_header = header
    hooks.keys.each do |key|
      value = hooks[key].call(self)
      if not value.is_a?(String)
        puts "Error while evaluating the hook for #{key}. Returned a #{value.class} valued as '#{value}'. Calling to_s."
      end
      generated_header = generated_header.gsub key.to_s, value.to_s
    end
    generated_header
  end
  
  def add_header header, old_header = nil
    content = ""
    file = File.new absolute_path, "r"
    file.each do |line|
      content += line
    end
    file.close
    
    content.gsub!(old_header, "") unless old_header.nil?
    content = header + content
    
    file = File.new absolute_path, "w"
    file.puts content
    file.close
  end
  
  protected

  def modifications
    @mods = version_control.history path if @mods.nil?
    @mods
  end
  
  def username
    Etc.getlogin
  end
end