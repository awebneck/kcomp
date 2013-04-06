require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe KComp do
  describe "constructor" do
    it "should raise a CyclicDependencyError if there are cyclic dependencies in the src files of the provided directory" do
      lambda { KComp.new CYCLIC_SRC_1, DEST }.should raise_error KComp::CyclicDependencyError
      lambda { KComp.new CYCLIC_SRC_2, DEST }.should raise_error KComp::CyclicDependencyError
    end

    it "should raise a MissingDependencyError if there are imported files that can't be found" do
      lambda { KComp.new MISSING_DEP_SRC, DEST }.should raise_error KComp::MissingDependencyError
    end
  end

  describe "instance methods" do
    let(:comp) { KComp.new GOOD_SRC, DEST }
    let(:undef) { KComp.new UNDEFINED_VAR_SRC, DEST }

    describe "compile!" do

      it "should create any destination directories it needs (as dictated by the source directory structure)" do
        FileUtils.rm_rf DEST + "/*"
        comp.compile!
        Dir.exists?(DEST + "/somedir").should be_true
      end

      it "should create a single html file for each regular kit file" do
        comp.compile!
        File.exists?(DEST + "/inc1.html").should be_false
        File.exists?(DEST + "/inc2.html").should be_false
        File.exists?(DEST + "/somedir/inc3.html").should be_false
        File.exists?(DEST + "/inc4.html").should be_false
        File.exists?(DEST + "/inc5.html").should be_true
        File.exists?(DEST + "/somedir/inc6.html").should be_true
        File.exists?(DEST + "/inc7.html").should be_true
        File.exists?(DEST + "/inc8.html").should be_true
        File.exists?(DEST + "/inc9.html").should be_true
        File.exists?(DEST + "/inc10.html").should be_true
        File.exists?(DEST + "/inc11.html").should be_true
        File.exists?(DEST + "/inc12.html").should be_true
        File.exists?(DEST + "/test-inclusion.html").should be_true
      end

      it "should not create an html file for partials" do
        comp.compile!
        File.exists?(DEST + "/partial1.html").should be_false
        File.exists?(DEST + "/partial2.html").should be_false
        File.exists?(DEST + "/partial3.html").should be_false
      end

      describe "generated files" do
        it "should contain any valid variable references" do
          comp.compile!
          f = File.read(DEST + "/test-inclusion.html")
          f.should =~ /VAR 1/
          f.should =~ /VAR 2/
          f.should =~ /VAR 3/
          f.should =~ /VAR 4/
          f.should =~ /VAR 5/
          f.should =~ /VAR 6/
          f.should =~ /VAR 7/
          f.should =~ /VAR 8/
          f.should =~ /VAR 9/
          f.should =~ /VAR 10/
          f.should =~ /VAR 11/
          f.should =~ /VAR 12/
        end

        it "should contain any inclusions" do
          comp.compile!
          f = File.read(DEST + "/inc10.html")
          f.scan(/INCLUSION 11/).length.should == 1
          f.scan(/PARTIAL 3/).length.should == 1
          f = File.read(DEST + "/test-inclusion.html")
          f.scan(/INCLUSION 1$/).length.should == 2
          f.scan(/INCLUSION 2/).length.should == 1
          f.scan(/INCLUSION 3/).length.should == 1
          f.scan(/INCLUSION 4/).length.should == 1
          f.scan(/INCLUSION 5/).length.should == 1
          f.scan(/INCLUSION 6/).length.should == 1
          f.scan(/INCLUSION 7/).length.should == 1
          f.scan(/INCLUSION 8/).length.should == 1
          f.scan(/INCLUSION 9/).length.should == 1
          f.scan(/INCLUSION 10/).length.should == 1
          f.scan(/INCLUSION 11/).length.should == 1
          f.scan(/PARTIAL 1/).length.should == 1
          f.scan(/PARTIAL 2/).length.should == 1
          f.scan(/PARTIAL 3/).length.should == 1
          f.scan(/VAR 1$/).length.should == 2
          f.scan(/VAR 2/).length.should == 1
          f.scan(/VAR 3/).length.should == 1
          f.scan(/VAR 4/).length.should == 1
          f.scan(/VAR 5/).length.should == 1
          f.scan(/VAR 6/).length.should == 1
          f.scan(/VAR 7/).length.should == 1
          f.scan(/VAR 8/).length.should == 1
          f.scan(/VAR 9/).length.should == 1
          f.scan(/VAR 10/).length.should == 1
          f.scan(/VAR 11/).length.should == 1
          f.scan(/VAR 12/).length.should == 1
        end
      end
    end

  end

  describe "class methods" do
    describe "compile!" do
      it "should create a new KComp instance with the provided source and destination directories and delegate compilation thereto" do
        kcomp = mock('KComp')
        KComp.should_receive(:new).with('blah', 'hat', {}).and_return kcomp
        kcomp.should_receive(:compile!)
        KComp.compile!('blah', 'hat')
      end
    end
  end
end
