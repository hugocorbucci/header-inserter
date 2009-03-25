require File.dirname(__FILE__) + '/../lib/header-inserter/svn_version_control'
require File.dirname(__FILE__) + '/../lib/header-inserter/modification'
require 'date'

describe SvnVersionControl do
  before(:all) do
    server_path = "http://svn.archimedes.org.br/public/mainarchimedes/rcparchimedes/"
    @svn = SvnVersionControl.new server_path
  end
  
  it "should be created with a server address" do
    @svn.path.should == "http://svn.archimedes.org.br/public/mainarchimedes/rcparchimedes/"
  end
  
  it "should retrieve log from the server according to the specified file" do
    log="""------------------------------------------------------------------------
r1451 | hugo.corbucci | 2009-03-17 17:21:03 -0300 (Ter, 17 Mar 2009) | 2 lines

Adding the projects for erase and tests for it. I forgot it before.
Hugo
------------------------------------------------------------------------
r1436 | hugo.corbucci | 2009-03-11 11:17:12 -0300 (Qua, 11 Mar 2009) | 2 lines

Updating the configs and adding a project set to help people configure Archimedes to develop.
Hugo (thanks to Mariana for finding this feature and telling me)
------------------------------------------------------------------------
"""
    @svn.retrieve_log("br.org.archimedes.config/trunk/ArchimedesProjectsSet.psf").should == log
  end
  
  it "should retrieve history from the server according to the specified file sorted" do
    date_log1 = DateTime.civil(2009, 03, 11, 11, 17, 12, -1/8)
    date_log2 = DateTime.civil(2009, 03, 17, 17, 21, 03, -1/8)
    first_mod = Modification.new 1436, "hugo.corbucci", date_log1, "Adding the projects for erase and tests for it. I forgot it before.\nHugo"
    second_mod = Modification.new 1451, "hugo.corbucci", date_log2, "Updating the configs and adding a project set to help people configure Archimedes to develop.\nHugo (thanks to Mariana for finding this feature and telling me)"
    @svn.history("br.org.archimedes.config/trunk/ArchimedesProjectsSet.psf").should == [first_mod, second_mod]
  end
end