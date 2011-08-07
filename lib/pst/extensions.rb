class Enumerator 
  def lazy_select(&block)
    Enumerator.new do |yielder| 
      self.each do |val| 
        yielder.yield(val) if block.call(val) 
      end
    end 
  end
end
