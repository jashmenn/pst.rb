require 'spec_helper'
testdatadir = File.dirname(__FILE__) + "/../test/data"

Pff = Java::ComPff


class Enumerator 
  def lazy_map(&block) 
    Enumerator.new do |yielder|
      self.each do |value|
        pp "calling #{value}"
        v = block.call(value)
        pp "got #{v} yielding"
        yielder.yield(block.call(value))
      end
    end
  end
end


describe "Pst::File" do
  before(:all) do
    @filename = testdatadir + "/TestArchive.pst"
    #@pstfile = Pst::File.new(@filename)
    @pstfile = Pff::PSTFile.new(@filename)
  end
  it "should have a name" do
    @pstfile.name.should eql("Archive Folders")
  end
  it "should have a root" do
    @pstfile.root.should_not be_nil
    #pp @pstfile.root
  end
  it "should have folder children" do
    # pp @pstfile.root

    # pp @pstfile.root.getSubFolders
    @pstfile.root.children_folders.first.name.should eql("Top of Personal Folders")

    @pstfile.root.children_folders.each do |f|
      pp [f.name,f]
    end
  end
end
