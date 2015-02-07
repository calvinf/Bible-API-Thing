require 'active_record'

class Verse < ActiveRecord::Base
    # the path is the path returned in the response for the passage
    # by the ABS Bible API
    validates :path, :presence => true

    # the reference requested (used to look up the verse)
    # we store this and use this as part of our cache key
    validates :reference_requested, :presence => true

    # the reference is the verse reference in the given translation
    validates :reference,	:presence => true

    # contents of the verse / passage
    validates :text, :presence => true

    # the translation of the verse / passage
    validates :translation, :presence => true

    # the copyright info for the verse
    validates :copyright, :presence => false

    # the verse_key
    validates :verse_key, :presence => true

    # http://guides.rubyonrails.org/association_basics.html#polymorphic-associations
    belongs_to :shareable, :polymorphic => true

    def to_s
        return "#{self.reference} (#{self.translation}): #{self.text}"
    end
end
