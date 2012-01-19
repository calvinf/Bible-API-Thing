class Pack
  #this pack can take a list of verses
  attr_accessor :verses

  def initialize(title = 'pack')
    # initialize the pack title (e.g. 'a')
    @title = title
  end
  def get_title
    puts @title.capitalize
  end
  def to_s
    if(defined? @verses)
      return @title.capitalize + ': ' + @verses.join(', ')
    else
      return @title.capitalize
    end
  end
end
