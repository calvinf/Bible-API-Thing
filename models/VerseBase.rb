class VerseBase
    attr_accessor :reference
    attr_accessor :text
    attr_accessor :translation

    def initialize(options = {})
        @reference = options[:reference]
        @text = options[:text]
        @translation = options[:translation]
    end

    def to_s
        return "#{self.reference} (#{self.translation}): #{self.text}"
    end
end
