require 'date'

class Modification
  include Comparable
  
  @@revision_format = /r(\d{1,}) \| (\S+) \| (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) ([+|-]?\d{2})(\d{2}) .* \| \d{1,} line[s]?\n\n(.*)\n/m
  @@svn_time_format = "%Y-%m-%d %H:%M:%S %z"
  attr_reader :revision, :author, :date, :log
  
  def Modification.parse text_log
    if @@revision_format.match text_log
      revision = $1.to_i
      author = $2
      time_zone = ($4 + ":" + $5)
      date = DateTime.strptime($3 + " " + time_zone, @@svn_time_format)
      log = $6
      Modification.new revision, author, date, log
    end
  end
  
  def initialize revision, author, date, log
    @revision = revision
    @author = author
    @date = date
    @log = log
  end
  
  def <=> other
    revision <=> other.revision
  end
end