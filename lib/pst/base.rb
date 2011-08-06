
class Java::ComPff::PSTFile
  def name
    self.getMessageStore.getDisplayName
  end

  alias_method :root, :getRootFolder 
end


class Java::ComPff::PSTFolder
  def name
    self.getDisplayName
  end

  def children_folders
    Enumerator.new do |yielder|
      self.getSubFolders.each do |f|
        yielder.yield f
        f.children_folders.each do |fc|
          yielder.yield fc
        end
      end
    end
  end

end
