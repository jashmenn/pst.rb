require 'spec_helper'
testdatadir = File.dirname(__FILE__) + "/../test/data"

Pff = Java::ComPff

describe "Pst::File" do

  before(:all) do
    @filename = testdatadir + "/albert_meyers_000.pst"
    #@pstfile = Pst::File.new(@filename)
    @pstfile = Pff::PSTFile.new(@filename)
  end
  it "should have a name" do
    @pstfile.name.should eql("albert_meyers_000")
  end

  it "should have a filename" do
    @pstfile.filename.should eql(@filename)
  end

  it "should have a root" do
    @pstfile.root.should_not be_nil
  end

  it "should tell root about itself" do
    @pstfile.root.file.should eql(@pstfile)
    @pstfile.root.file.name.should eql(@pstfile.name)
  end

  context "with sub folders" do

    before(:all) do
      @folder_names = @pstfile.root.sub_folders.inject({}){|acc,f|
        acc[f.name] = f
        acc
      }
    end

    it "should have sub folders" do
      @folder_names.should have_key("ExMerge - Meyers, Albert")
      @folder_names.should have_key("meyers-a")
    end

    it "should have content counts" do
      @folder_names["Deleted Items"].getContentCount.should eql(1130)
      @folder_names["Inbox"].getContentCount.should eql(22)
    end

    it "should have a path" do
      @folder_names["Inbox"].path.should eql("/Top of Personal Folders/Inbox")
    end

  end

  context "with emails" do
    before(:all) do
      @folders = @pstfile.root.sub_folders.inject({}){|acc,f|
        acc[f.name] = f
        acc
      }
      @folder = @folders["Deleted Items"]
      @email  = @folder.children.first
    end

    it "should have basic attributes" do
      @email.subject.should eql("Re: deal 539246.1 REliant HLP dms 7634/7636") 
      @email.display_to.should eql("Joy Werner")
    end

    it "should know about its folder" do
      @email.folder.should eql(@folder)
    end
  end

end
