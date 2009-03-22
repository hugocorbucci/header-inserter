require 'lib/header-inserter/project'
require 'ftools'
require 'fileutils'

describe ProjectFile do
  before(:each) do
    @project = Project.new "/tmp/header-insert-test-project"
  end
  
  def create_file absolute_path, content
    File.makedirs File.dirname(absolute_path)
    file = File.new absolute_path, "w"
    file.puts content
    file.close
  end
  
  it "should be created with a project and a path relative to that project" do
    file = ProjectFile.new @project, "non-existing-file.rb"
    file.absolute_path.should == "/tmp/header-insert-test-project/non-existing-file.rb"
  end
  
  it "should be assume '/' as a root path if the project is nil" do
    file = ProjectFile.new nil, "testfile.rb"
    file.absolute_path.should == "/testfile.rb"
  end
  
  it "should compare based on the relative path" do
    file = ProjectFile.new @project, "a.file"
    other_file = ProjectFile.new @project, "z.file"
    (file<=>other_file).should == -1
    (other_file<=>file).should == 1
    (file<=>file).should == 0
    (other_file<=>other_file).should == 0
  end
  
  it "should equal based on the absolute and the path" do
    file = ProjectFile.new @project, "a.file"
    other_file = ProjectFile.new @project, "z.file"
    equal_file = ProjectFile.new @project, "a.file"
    
    file.should == file
    file.should_not == other_file
    file.should == equal_file
    
    other_file.should == other_file
    other_file.should_not == file
    other_file.should_not == equal_file
  end
  
  it "should retrieve an empty original header from a non existing file" do
    file = ProjectFile. new @project, "a.file"
    file.retrieve_original_header.should be_nil
  end
  
  it "should retrieve everything until package from an existing file" do
    file = ProjectFile. new @project, "my/project/A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}package my.project;\n\nclass A {}"
    file.retrieve_original_header.should == header
    FileUtils.rm_rf @project.path
  end
  
  it "should retrieve everything until import from an existing file without package" do
    file = ProjectFile. new @project, "A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}import java.util.Observable;\n\nclass A extends Observable {}"
    p file.retrieve_original_header
    file.retrieve_original_header.should == header
    FileUtils.rm_rf @project.path
  end
  
  it "should retrieve everything until class from an existing file without package or imports" do
    file = ProjectFile. new @project, "A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}class A {}"
    file.retrieve_original_header.should == header
    FileUtils.rm_rf @project.path
  end
end