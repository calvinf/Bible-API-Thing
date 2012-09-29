class Verse 
    include MongoMapper::Document

    key :reference,	String, :required => true
    key :text,		String, :required => true
    key :translation,	String, :required => true
    key :cache_key,	String, :required => true
    #key :in_packs,	Array
    timestamps!

    before_validation :set_cache_key

    def to_s
	return "#{self.reference} (#{self.translation}): #{self.text}"
    end

    private
    def set_cache_key
	self.cache_key = translation.downcase + '::' + reference.downcase.gsub(/\s+/, "")
    end
end
