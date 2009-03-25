require File.dirname(__FILE__) + '/../lib/header-inserter/modification'
require 'date'

describe Modification do
  it "should be created with revision number, author, date and log entry" do
    date = Date.today
    mod = Modification.new 1, "Hugo", date, "Just a test"
    mod.author.should == "Hugo"
    mod.revision.should == 1
    mod.date.should == date
    mod.log.should == "Just a test"
  end
  
  it "should parse a complete log entry" do
    date = DateTime.strptime "2009-03-17 17:21:03 -0300", "%Y-%m-%d %H:%M:%S %z"
    mod = Modification.parse """r1451 | hugo.corbucci | 2009-03-17 17:21:03 -0300 (Ter, 17 Mar 2009) | 2 lines

Adding the projects for erase and tests for it. I forgot it before.
Hugo
"""
    mod.author.should == "hugo.corbucci"
    mod.revision.should == 1451
    mod.date.should == date
    mod.log.should == "Adding the projects for erase and tests for it. I forgot it before.\nHugo"
  end
  
  it "should sort according to the revision" do
    date = Date.today - 1
    first_mod = Modification.new 1, "Hugo", date, "Just a test"
    second_mod = Modification.new 2, "Hugo", Date.today, "Just a test"
    equal_mod = Modification.new 1, "Hugo", date, "Just a test"
    (first_mod<=>second_mod).should == -1
    (second_mod<=>first_mod).should == 1
    (first_mod<=>first_mod).should == 0
    (first_mod<=>equal_mod).should == 0
  end
end