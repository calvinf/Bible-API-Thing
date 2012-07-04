class Verse 
  attr_accessor :reference
  attr_accessor :text
  attr_accessor :translation
  attr_accessor :cache_prefix

  def initialize(options = {})
    # accessible instance variables
    @reference    = options[:reference]
    @text         = options[:text]
    @translation  = options[:translation]
    @cache_prefix = options[:cache_prefix] ||= 'verse'

    # not accessible stuff
    @client = options[:client]
  end

  def to_s
    return "#{@reference} (#{@translation}): #{@text}"
  end

  def to_json(*a)
    {
	'reference'   => @reference,
	'text'        => @text,
	'translation' => @translation
    }.to_json(*a)
  end

  def cache
    #puts "Caching to: " + key
    @client.set(self.cache_key, @text)
  end

  def cache_key
    return @cache_prefix + '::' + @translation.downcase + '::' + @reference.downcase.gsub(/\s+/, "")
  end
end
