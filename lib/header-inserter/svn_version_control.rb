class SvnVersionControl
  attr_reader :path
  @@entry_start = /^[-]{72}$/
  @@valid = /\s*r\d{1,} \| \S+ \| .* | \d{1,} line[s]?\n\n.*\n/
  
  def initialize server_path
    @path = server_path
    @logs = {}
  end

  def retrieve_log file_path
    if not @logs.has_key?(file_path)
      @logs[file_path] = %x[svn log #{@path + file_path}]
    end
    @logs[file_path]
  end
  
  def history file_path
    mods = []
    log = retrieve_log file_path
    log.split(@@entry_start).each do |entry|
      mods << Modification.parse(entry) if @@valid.match(entry)
    end
    mods.reverse
  end
end