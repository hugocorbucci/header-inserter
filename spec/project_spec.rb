require File.dirname(__FILE__) + '/spec_helper.rb'
require 'ftools'
require 'fileutils'
require 'lib/header-inserter/project_file'

describe Project do
  
  before(:all) do
    @project_path = "/tmp/project#{@rand}"
    File.makedirs "#{@project_path}/src/my/project/logic"
    File.makedirs "#{@project_path}/test/my/project/logic"
    File.makedirs "#{@project_path}/bin/my/project/logic"
    create_file "#{@project_path}/src/my/project/Main.java", "package my.project; class Main {}"
    create_file "#{@project_path}/src/my/project/logic/Logic.java", "package my.project.logic; class Logic {}"
    create_file "#{@project_path}/test/my/project/logic/LogicTest.java", "package my.project.logic; class LogicTest {}"
    create_file "#{@project_path}/bin/my/project/logic/Logic.class", (1..500).to_a.map{|x| rand(256)}.pack("c*")
    create_file "#{@project_path}/Util.java", "class Util {}"
    create_file "#{@project_path}/../Useless.java", "package invalid; class Useless {}"
  end
  
  def create_file path, content
    file = File.new path, "w"
    file.puts content
    file.close
  end
  
  def to_project_file project, array
    array.map { |file| ProjectFile.new project, file }
  end
  
  it "should be created with a relative path" do
    relative_path = "a/path"
    project = Project.new relative_path
    project.path.should == File.expand_path(relative_path)
  end
  
  it "should be created with an absolute path" do
    absolute_path = "/an/absolute/path"
    project = Project.new absolute_path
    project.path.should == absolute_path
  end
  
  it "should be created with an absolute path with separator" do
    absolute_path = "/an/absolute/path"
    project = Project.new(absolute_path+File::SEPARATOR)
    project.path.should == absolute_path
  end
  
  it "should list nothing if there are no files of that type" do
    project = Project.new @project_path
    project.list(:rb).should == []
  end
  
  it "should list nothing if there are no files matching the pattern" do
    project = Project.new @project_path
    project.list(/Holy Example Batman/).should == []
  end
  
  it "should list nothing on a non-existing project" do
    project = Project.new(@project_path + "/" + rand(100000).to_s)
    project.list(:rb).should == []
  end
  
  it "should list all files from an extension on aproject with many" do
    project = Project.new @project_path
    expected = to_project_file project, ["src/my/project/Main.java", "src/my/project/logic/Logic.java", "test/my/project/logic/LogicTest.java", "Util.java"]
    project.list(:java).sort.should == expected.sort
  end
  
  it "should list a single file with an extension on a project" do
    project = Project.new @project_path
    expected = to_project_file project, ["bin/my/project/logic/Logic.class"]
    project.list(:class).sort.should == expected.sort
  end
  
  it "should list files matching a pattern a project with many" do
    project = Project.new @project_path
    expected = to_project_file project, ["src/my/project/Main.java", "src/my/project/logic/Logic.java"]
    project.list(/src\/.*.java/).sort.should == expected.sort
  end
  
  it "should list a single file matching a pattern a project" do
    project = Project.new @project_path
    expected = to_project_file project, ["Util.java"]
    project.list(/^((?!\/).)*\..*/).sort.should == expected.sort
  end
  
  it "should compare based on path" do
    project = Project.new @project_path
    other_project = Project.new "/an/absolute/path"
    equal_project = Project.new @project_path
    
    (project<=>project).should == 0
    (project<=>other_project).should == 1
    (other_project<=>project).should == -1
    (project<=>equal_project).should == 0
  end
  
  after(:all) do
    File.delete "#{@project_path}/../Useless.java"
    FileUtils.rm_rf @project_path
  end
end