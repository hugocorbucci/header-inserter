require File.dirname(__FILE__) + '/../../lib/header-inserter/project'
require File.dirname(__FILE__) + '/../../lib/header-inserter/project_file'
require File.dirname(__FILE__) + '/../../lib/header-inserter/modification'
require 'ftools'

project = Project.new("/tmp/version_controlled_project")

def create_file path, content
  FileUtils.makedirs File.dirname(path)
  file = File.new path, "w"
  file.puts content
  file.close
end

def obtain_file file
  # system("svn co http://svn.archimedes.org.br/public/header-insert/#{file.path}")
  create_file file.absolute_path, "a test"
end

Given /a file not version controlled/ do
  @file = ProjectFile.new project, "my.file"
  create_file @file.absolute_path, "Just a new file"
end

Given /a file recently under version control/ do
  path = "single_mod.file"
  @file = ProjectFile.new project, path
  obtain_file @file
end

Given /a file under version control for some time/ do
  path = "multiple_mods.file"
  @file = ProjectFile.new project, path
  obtain_file @file
end

When /I retrieve its history/ do
  vcs = @file.version_control
  @history = vcs.history @file
end

Then /I should receive an empty history/ do
  @history.should == []
end

Then /I should receive a history with modifications:/ do |modifications|
  mods = []
  modifications.hashes.each do |hash|
    mods << Modification.new(hash["revision"], hash["author"], hash["date"], hash["log"])
  end
  @history.should == mods
end

at_exit do
  FileUtils.rm_rf project.path
end