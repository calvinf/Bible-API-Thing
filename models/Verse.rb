class Verse
    include MongoMapper::Document

    # the path is the path returned in the response for the passage
    # by the ABS Bible API
    key :path, String, :required => true

    # the reference requested (used to look up the verse)
    # we store this and use this as part of our cache key
    key :reference_requested, String, :required => true

    # the reference is the verse reference in the given translation
    key :reference,	String, :required => true

    # contents of the verse / passage
    key :text, String, :required => true

    # the translation of the verse / passage
    key :translation, String, :required => true

    # the cache_key
    key :cache_key,	String, :required => true

    # add timestamps to the model
    timestamps!

    before_validation :set_cache_key

    def to_s
        return "#{self.reference} (#{self.translation}): #{self.text}"
    end

    private
    def set_cache_key
        # our cache key is a combination of the translation and
        # the reference requested (used to look up the verse)
        self.cache_key = translation.downcase + '::' + reference_requested.downcase.gsub(/\s+/, "")
    end
end
