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

  def name
    self.getDisplayName
  end

  def sub_folders
    Enumerator.new do |yielder|
      self.getSubFolders.each do |f|
        f.parent = self 
        yielder.yield f
        f.sub_folders.each do |fc|
          fc.parent = f
          yielder.yield fc
        end
      end
    end
  end

  def children
    Enumerator.new do |yielder|
      while kid = getNextChild
        kid.folder = self
        yielder.yield kid
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

end

class Java::ComPff::PSTMessage 
  attr_accessor :folder

  alias_method :subject, :getSubject
  alias_method :display_to, :getDisplayTo
  alias_method :num_recipients, :getNumberOfRecipients
  alias_method :num_attachments, :getNumberOfAttachments

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
    Enumerator.new do |yielder|
      i = 0
      while i < self.getNumberOfRecipients
        recipient = self.getRecipient(i)
        yielder.yield recipient
        i = i + 1
      end
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
