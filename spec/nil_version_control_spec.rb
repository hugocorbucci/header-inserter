require File.dirname(__FILE__) + '/../lib/header-inserter/nil_version_control'

describe NilVersionControl do
  it "should have only one instance" do
    instance1 = NilVersionControl.new
    instance2 = NilVersionControl.new
    instance1.should == instance2
  end
  
  it "should always return an empty history" do
    vc = NilVersionControl.new
    vc.history("a").should == []
    vc.history("http://svn.archimedes.org.br/public/mainarchimedes/rcparchimedes/br.org.archimedes.izpack/ArchimedesProjectSet.psf").should == []
  end
end