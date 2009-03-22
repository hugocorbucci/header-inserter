require 'lib/header-inserter/project'
require 'lib/header-inserter/project-file'
require 'ftools'

non_existing = "/tmp/non_existing_project" + rand(1000000).to_s

empty = "/tmp/empty_project" + rand(1000000).to_s
Dir.mkdir empty

non_structured = "/tmp/non_structured_project" + rand(1000000).to_s
Dir.mkdir non_structured
main = File.new non_structured+"/Main.java", "w"
main.puts "class Main {}"
main.close
mainTest = File.new non_structured+"/MainTest.java", "w"
mainTest.puts "class MainTest {}"
mainTest.close
mainTestClass = File.new non_structured+"/MainTest.class", "w"
array = (1..500).to_a.map{|x| rand(256)}
mainTestClass.puts array.pack("c*")
mainTestClass.close

structured = "/tmp/structured_project" + rand(1000000).to_s
File.makedirs structured+"/src/my/project/internal"
File.makedirs structured+"/bin/my/project/internal"
File.makedirs structured+"/test/my/project/internal"
main = File.new structured+"/src/my/project/Main.java", "w"
main.puts "package my.project; class Main {}"
main.close
logic = File.new structured+"/src/my/project/internal/Logic.java", "w"
logic.puts "package my.project.internal; class Logic {}"
logic.close
logicClass = File.new structured+"/bin/my/project/internal/Logic.class", "w"
array = (1..500).to_a.map{|x| rand(256)}
logicClass.puts array.pack("c*")
logicClass.close
logicTest = File.new structured+"/test/my/project/internal/LogicTest.java", "w"
logicTest.puts "package my.project.internal; class LogicTest {}"
logicTest.close

Given /a[n]? (\S*) project/ do |type|
  @project = Project.new eval(type.gsub("-","_"))
end

When /I list "(.*)" files/ do |type|
  @files = @project.list(type.to_sym)
end

Then /I should get nothing/ do
  @files.should == []
end

Then /I should get (\[".*"(?:, ".*")?\])/ do |list|
  @files.sort.should == eval(list).map{|path| ProjectFile.new @project, path }.sort
end

at_exit do
  FileUtils.rm_rf empty
  FileUtils.rm_rf non_structured
  FileUtils.rm_rf structured
end
