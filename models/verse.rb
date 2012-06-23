class Verse 
  attr_accessor :reference
  attr_accessor :text
  attr_accessor :translation

  def initialize(reference, text, translation)
    @reference = reference
    @text = text
    @translation = translation
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

  end
end
