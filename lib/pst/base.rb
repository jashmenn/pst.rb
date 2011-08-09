require 'digest/sha1'

class Java::ComPff::PSTFile
  attr_accessor :collection
  attr_accessor :filename
  alias_method :file, :getFileHandle

  def initialize(name)
    super(name)
    @filename = name
  end

  def name
    self.getMessageStore.getDisplayName
  end

  def root
    f = self.getRootFolder
    f.file = self
    f
  end
end

class Java::ComPff::PSTFolder
  attr_accessor :file
  attr_reader :parent
  alias_method :subfolder_count, :getSubFolderCount
  alias_method :email_count, :getContentCount

  def name
    self.getDisplayName
  end

  def sub_folders
    Enumerator.new do |yielder|
      self.getSubFolders.each do |f|
        f.parent = self 
        yielder.yield f
        f.sub_folders.each do |fc|
          yielder.yield fc
        end
      end
    end
  end

  def children
    # this doesn't work dont use it.  it doesn't work because
    # Enumerator does some sort of non-deterministic lookaheads
    # that move the cursor out from underneith the underlying
    # java-pst library
    #
    # Maybe once I understand Enumerator better we can fix this.
    raise "TODO"
    Enumerator.new do |yielder|
      max = self.email_count
      idx = 0
      while idx < max 
        self.moveChildCursorTo(idx)
        kid = self.getNextChild
        kid.folder = self
        yielder.yield kid
        idx = idx + 1
      end
    end
  end

  def filename 
    self.file.filename
  end

  def path
    levels = [self.name]
    f = self
    while p = f.parent
      levels << p.name
      f = p
    end
    levels.reverse.join("/")
  end

  def human_id
    "%s:%s:%s" % [self.file.collection || "no-collection", filename, path]
  end

  def hash_string
    Digest::SHA1.hexdigest(human_id)
  end

  def parent=(the_parent)
    @parent   = the_parent 
    self.file = the_parent.file
  end

  def creation_time
    t = self.getCreationTime || self.getLastModificationTime
    t.andand.to_time
  end

end

class Java::ComPff::PSTMessage 
  attr_accessor :folder

  alias_method :subject, :getSubject
  alias_method :display_to, :getDisplayTo
  alias_method :num_recipients, :getNumberOfRecipients
  alias_method :num_attachments, :getNumberOfAttachments
  alias_method :sender_name, :getSenderName
  alias_method :sender_email, :getSenderEmailAddress
  alias_method :original_subject, :getOriginalSubject
  #alias_method :body, :getBody
  alias_method :html_body, :getBodyHTML

  # things to pay attention to
  # next.getDescriptorNode().descriptorIdentifier+"";
  # next.getSentRepresentingName() + " <"+ next.getSentRepresentingEmailAddress() +">";
  # next.getReceivedByName() + " <"+next.getReceivedByAddress()+">" + 
  # next.displayTo();
  # next.getClientSubmitTime();

  def human_id
    "%s:%s:%s:%s" % [ folder.human_id, self.getClientSubmitTime.to_s, self.getInternetMessageId, self.subject ]
  end

  def hash_string
    Digest::SHA1.hexdigest(human_id)
  end

  def pretty_string
    "[%s] %s - %s <%s> %s <%s> %s %s a:%s" % [
          self.getDescriptorNode.descriptorIdentifier,
          self.getSubject,
          self.getSentRepresentingName,
          self.getSentRepresentingEmailAddress,
          self.getReceivedByName,
          self.getReceivedByAddress,
          self.displayTo,
          self.getClientSubmitTime,
          self.hasAttachments]
  end

  def recipients
    recip = []
    #Enumerator.new do |yielder|
      i = 0
      while i < self.getNumberOfRecipients
        recipient = self.getRecipient(i)
        recip << recipient
        i = i + 1
      end
    #end
    recip
  end

  def sent_at
    self.getClientSubmitTime.andand.to_time
  end

  def contents
    # this is because [Pff::PSTContact, Pff::PSTTask, Pff::PSTActivity, Pff::PSTRss]
    # are all PSTMessages but they throw a npe if you call getBody
    begin
      return self.getBody
    rescue
    end
    begin
      return self.toString
    rescue
    end
    raise "no contents found in #{self}"
  end

  def calculated_recipients_string
    self.recipients.collect{|r| r.pretty_string}.join(", ")
  end

  def recipients_string
    orig = self.getRecipientsString
    if orig == "No recipients table!"
      calculated_recipients_string
    else
      orig
    end
  end
end

class Java::ComPff::PSTRecipient
  alias_method :name, :getDisplayName
  alias_method :email, :getEmailAddress
  alias_method :smtp, :getSmtpAddress

  def pretty_string
    "%s <%s>" % [name, email]
  end

  def human_id
    pretty_string
  end

  def hash_string
    Digest::SHA1.hexdigest(human_id)
  end
end

class Java::ComPff::PSTAttachment
  # todo hash
  def pretty_string
    "[%s] %s <%s, %d>" % [self.getContentId, self.getFilename, self.getMimeTag, self.getSize]
  end
end
