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
    @filename = testdatadir + "/albert_meyers_000.pst"
    #@pstfile = Pst::File.new(@filename)
    @pstfile = Pff::PSTFile.new(@filename)
  end
  it "should have a name" do
    @pstfile.name.should eql("albert_meyers_000")
  end

  it "should have a root" do
    @pstfile.root.should_not be_nil
    #pp @pstfile.root
  end

  context "with sub folders" do

    before(:all) do
      @folder_names = @pstfile.root.sub_folders.inject({}){|acc,f|
        acc[f.name] = f.getContentCount 
        acc
      }
    end

    it "should have sub folders" do
      @folder_names.should have_key("ExMerge - Meyers, Albert")
      @folder_names.should have_key("meyers-a")
      #@pstfile.root.sub_folders.each do |f|
      #  pp [f.name,f]
      #end
    end

    it "should have content counts" do
      @folder_names["Deleted Items"].should eql(1130)
      @folder_names["Inbox"].should eql(22)
    end

  end

  context "with emails" do
    before(:all) do
      @folders = @pstfile.root.sub_folders.inject({}){|acc,f|
        acc[f.name] = f
        acc
      }
      @folder = @folders["Deleted Items"]
    end

    it "should have content counts" do
      child = @folder.children.first
      child.subject.should eql("Re: deal 539246.1 REliant HLP dms 7634/7636") 
      child.display_to.should eql("Joy Werner")
    end
  end

end
