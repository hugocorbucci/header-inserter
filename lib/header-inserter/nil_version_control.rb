class NilVersionControl
  @@instance = self.new
  
  def NilVersionControl.new
    @@instance
  end
  
  def history file_path
    []
  end
end