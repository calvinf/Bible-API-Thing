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
end
