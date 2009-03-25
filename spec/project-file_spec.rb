require 'lib/header-inserter/project'
require 'lib/header-inserter/svn_version_control'
require 'lib/header-inserter/modification'
require 'ftools'
require 'fileutils'

describe ProjectFile do
  before(:each) do
    @project = Project.new "/tmp/header-insert-test-project"
  end
  
  it "should be created with a project, a path relative to that project (assuming NilVersionControl)" do
    file = ProjectFile.new @project, "non-existing-file.rb"
    file.absolute_path.should == "/tmp/header-insert-test-project/non-existing-file.rb"
    file.version_control.should be_kind_of(NilVersionControl)
  end
  
  it "should be created with a project, a path relative to that project and a version control system" do
    file = ProjectFile.new @project, "non-existing-file.rb", SvnVersionControl.new("http://svn.archimedes.org.br/public/")
    file.absolute_path.should == "/tmp/header-insert-test-project/non-existing-file.rb"
    file.version_control.should be_kind_of(SvnVersionControl)
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
    file = ProjectFile.new @project, "a.file"
    file.original_header.should be_nil
  end
  
  it "should retrieve all the header until package from an existing file" do
    file = ProjectFile.new @project, "my/project/A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}package my.project;\n\nclass A {}"
    file.original_header.should == header
  end
  
  it "should retrieve all the header until import from an existing file without package" do
    file = ProjectFile.new @project, "A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}import java.util.Observable;\n\nclass A extends Observable {}"
    file.original_header.should == header
  end
  
  it "should retrieve all the header until class from an existing file without package or imports" do
    file = ProjectFile.new @project, "A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}class A {}"
    file.original_header.should == header
  end
  
  it "should retrieve created on information from modifications from version control" do
    mock_version_control = mock(NilVersionControl.new)
    mock_version_control.should_receive(:history).once.and_return([])
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.created_on.should == Date.today
    
    date = DateTime.parse("2009-01-01T17:32:45-03:00")
    mock_version_control = mock(NilVersionControl.new)
    mock_version_control.should_receive(:history).once.and_return([Modification.new 134, "hugo", date, "Unique entry"])
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.created_on.should == date
    
    mock_version_control = mock(NilVersionControl.new)
    date1 = DateTime.parse("2009-01-01T17:32:45-03:00")
    date2 = DateTime.parse("2009-02-12T09:02:56+08:00")
    date3 = DateTime.parse("2009-03-24T19:45:30+00:00")
    mods = [Modification.new(134, "hugo", date1, "First entry"),
            Modification.new(531, "mari", date2, "Second entry"),
            Modification.new(1039, "hugo", date3, "Third and last entry")]
    mock_version_control.should_receive(:history).once.and_return(mods)
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.created_on.should == date1
  end
  
  it "should retrieve contributors from modifications from version control with unique names sorted by first occurrence" do
    mock_version_control = mock(NilVersionControl.new)
    mock_version_control.should_receive(:history).once.and_return([])
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.contributors.should == ["night"]
    
    date = DateTime.parse("2009-01-01T17:32:45-03:00")
    mock_version_control = mock(NilVersionControl.new)
    mock_version_control.should_receive(:history).once.and_return([Modification.new 134, "hugo", date, "Unique entry"])
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.contributors.should == ["hugo"]
    
    mock_version_control = mock(NilVersionControl.new)
    date1 = DateTime.parse("2009-01-01T17:32:45-03:00")
    date2 = DateTime.parse("2009-02-12T09:02:56+08:00")
    date3 = DateTime.parse("2009-03-24T19:45:30+00:00")
    date4 = DateTime.parse("2009-03-24T20:01:13-03:00")
    date5 = DateTime.parse("2009-03-24T20:11:16-03:00")
    mods = [Modification.new(134, "hugo", date1, "First entry"),
            Modification.new(531, "mari", date2, "Second entry"),
            Modification.new(1039, "hugo", date3, "Third entry"),
            Modification.new(1045, "kung", date4, "Fourth entry"),
            Modification.new(1253, "mari", date5, "Last entry")]
    mock_version_control.should_receive(:history).once.and_return(mods)
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.contributors.should == ["hugo", "mari", "kung"]
  end
  
  it "should have a nil version control by default" do
    file = ProjectFile.new @project, "A.java"
    header = "/**\n * A simple test\n */\n\n"
    
    create_file file.absolute_path, "#{header}class A {}"
    file.version_control.should == NilVersionControl.new
  end
  
  it "should retrieve a nil history if not under subversion control"
  it "should retrieve a single modification history if recently under subversion control"
  it "should retrieve multiple modifications history if under subversion control for a long time"
  
  it "should generate a header according to a header format and hooks" do
    header = "# My fine header.\n# It has the date (REPLACE_DATE) and the first contributor (FIRST_CONTRIBUTOR).\n # And ends like nothing\n"
    hooks = { :REPLACE_DATE => lambda { |file| file.created_on.strftime "%Y-%m-%d, %H:%M:%S" },
              :FIRST_CONTRIBUTOR => lambda {|file| file.contributors[0] } }

    expected_header = "# My fine header.\n# It has the date (2009-03-24, 21:43:58) and the first contributor (hugo).\n # And ends like nothing\n"
    
    date = DateTime.parse "2009-03-24T21:43:58-03:00"
    mock_version_control = mock(NilVersionControl.new)
    mock_version_control.should_receive(:history).once.and_return([Modification.new 324, "hugo", date, "Unique entry"])
    file = ProjectFile.new @project, "A.java", mock_version_control
    file.generate_header(header, hooks).should == expected_header
  end
  
  it "should add a header at the beginning of the file" do
    new_header = "/**\n * My fine header.\n * It has the date (2009-03-24, 21:43:58) and the first contributor (hugo).\n * And ends like nothing\n */\n\n"
    content = "class A {}\n"
    
    file = ProjectFile.new @project, "A.java"
    create_file file.absolute_path, content
    file.add_header(new_header)
    
    read_content(file.absolute_path).should == new_header + content
  end
  
  it "should add a header at the beginning of the file and remove the one specified" do
    new_header = "/**\n * My fine header.\n * It has the date (2009-03-24, 21:43:58) and the first contributor (hugo).\n * And ends like nothing\n */\n\n"
    stupid_header = "/** A stupid header */\n\n"
    content = "#{stupid_header}class A {}\n"
    
    file = ProjectFile.new @project, "A.java"
    create_file file.absolute_path, content
    file.add_header(new_header, stupid_header)
    
    read_content(file.absolute_path).should == new_header + content
  end
  
  after(:each) do
    FileUtils.rm_rf @project.path
  end
  
  protected
  
  
  def create_file absolute_path, content
    File.makedirs File.dirname(absolute_path)
    file = File.new absolute_path, "w"
    file.puts content
    file.close
  end
  
  def read_content absolute_path
    file = File.new absolute_path, "r"
    content = file.inject { |result , line| result + line }
    file.close
    content
  end
end