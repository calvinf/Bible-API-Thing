require 'active_record'

class Pack < ActiveRecord::Base
    # A pack can contain many verses
    # We're accessing via polymorphic association
    has_many :verses, :as => :shareable

    # Pack Title
    validates :title,
        presence: {message: 'A pack title must be provided.'},
        uniqueness: true

    # Pack Title Abbreviation
    validates :abbreviation,
        length: {maximum: 4, message: 'Pack abbreviation must be less than 4 characters.'}
end

# TODO move to an ActiveRecord::Migration instead
unless Pack.table_exists?
    ActiveRecord::Schema.define do
        create_table :packs do |t|
            t.string :title
            t.string :abbreviation
            #t.has_many :verses

            t.timestamps null: false
        end
    end
end
