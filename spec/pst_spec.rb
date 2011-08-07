require 'spec_helper'
testdatadir = File.dirname(__FILE__) + "/../test/data"

Pff = Java::ComPff

describe "PST" do

  before(:all) do
    @filename = testdatadir + "/albert_meyers_000.pst"
    @pstfile = Pff::PSTFile.new(@filename)

    @folders = @pstfile.root.sub_folders.inject({}){|acc,f|
      acc[f.name] = f
      acc
    }
    
  end

  context "PSTFile" do 

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
  end

  context "PSTFolder" do

    before(:all) do

    end

    it "should have sub folders" do
      @folders.should have_key("ExMerge - Meyers, Albert")
      @folders.should have_key("meyers-a")
    end

    it "should have content counts" do
      @folders["Deleted Items"].getContentCount.should eql(1130)
      @folders["Inbox"].getContentCount.should eql(22)
    end

    it "should have a path" do
      @folders["Inbox"].path.should eql("/Top of Personal Folders/Inbox")
    end

    it "should have a hash string" do
      @folders["Inbox"].human_id.should eql("no-collection:/Users/nmurray/projects/enron/software/pst.rb/spec/../test/data/albert_meyers_000.pst:/Top of Personal Folders/Inbox")
      @folders["Inbox"].hash_string.should eql("767d47f8134cd5c14786efd0274586b1065278e7")
    end

  end

  context "PSTMessage" do
    before(:all) do
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

    it "should have an id" do
      @email.human_id.should eql("no-collection:/Users/nmurray/projects/enron/software/pst.rb/spec/../test/data/albert_meyers_000.pst:/Top of Personal Folders/Deleted Items:Fri Apr 06 01:02:00 PDT 2001:<ML1KCRAP2G52RFDSYPSFSAQ0J30PDFMMB@zlsvr22>:Re: deal 539246.1 REliant HLP dms 7634/7636")
      @email.hash_string.should eql("c512b175785b28532146be7cdb165a5bbee4d130")
      # pp @email.pretty_string
    end

    it "should have the number of recipients" do
      @email.getNumberOfRecipients.should eql(1)
    end

    it "should iterate over recipients" do
      @email.recipients.count.should eql(1)
      #@email.recipients.each do |r|
      #  pp r
      #end
    end

  end

  describe "PSTRecipient" do
    before(:all) do
      @folder = @folders["Deleted Items"]
      @email = @folder.children.take(5).last

      @recipients = @email.recipients.inject({}){|acc,r|
        acc[r.name] = r
        acc
      }
    end

    it "should have a name" do
      @recipients.should have_key("Volume Management")
      @recipients.should have_key("Williams III")
      @recipients.should have_key("Bill")
    end

    it "should have an email field" do
      @recipients["Williams III"].email.should eql("Williams III")
      @recipients["Bill"].email.should eql("/O=ENRON/OU=NA/CN=RECIPIENTS/CN=Bwillia5")
    end

    it "should have a hash string" do
      @recipients["Bill"].hash_string.should eql("f161dd2a45952784c440bd5879684ae89b8b0523")
    end

  end

end
