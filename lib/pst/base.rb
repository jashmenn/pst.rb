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
  attr_accessor :parent

  def name
    self.getDisplayName
  end

  def sub_folders
    Enumerator.new do |yielder|
      self.getSubFolders.each do |f|
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
    "/" + levels.reverse.join("/")
  end

  #sha1 = Digest::SHA1.hexdigest('something secret')
end

class Java::ComPff::PSTMessage 
  attr_accessor :folder

  alias_method :subject, :getSubject
  alias_method :display_to, :getDisplayTo
end
