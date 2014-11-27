#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# all the other things we want to use
require 'pp'  # prettyprint (for errors and testing)

# other includes
require './api-key.rb'              # BIBLE_KEY
require './models/BibleSearch.rb'   # Bible Search
require './models/Pack.rb'          # Pack model
require './models/Verse.rb'         # Verse model
require './models/VerseBase.rb'     # VerseBase model

class BibleApi
    # Constants
    # amount of time to sleep between API calls
    SLEEP_TIME = 0.1

    def initialize(opts = {})
        @options = {
            :useMongo => true,
            :overwrite => false,
            :translations => ['eng-ESV']
        }.merge(opts)

        if @options[:useMongo]
            # TODO add error handling when server is unreachable
            MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
            MongoMapper.database = "versemachine"
        end
    end

    def get_pack_data(pack)
        # determine verses needed
        versesNeeded = self.get_verses_needed(pack)

        # get the verses
        verses = self.get_verses(versesNeeded)
        return verses
    end

    def get_verses_needed(pack)
        versesNeeded = []
        if @options[:useMongo]
            # only get the verses we don't already have in Mongo
            versesNeeded = self.check_for_verses(pack)
            if versesNeeded.length == 0
                puts "Pack #{pack.get_title}: all verses found in MongoDB"
                return
            end
        end

        puts "Verses needed for #{pack.get_title}: #{versesNeeded.to_s}"
        return versesNeeded
    end

    def get_verses(versesNeeded)
        # TODO optimize for multiple verses
        # using single-verse query for now in order to
        # be able to map a single reference_requested
        # to a single passage (easier to check for
        # existence in mongo already if we know this)

        # array of resulting verses
        verses = []

        bibleSearch = BibleSearch.new(@options[:translations])

        # TODO find a way to minize API calls and still keep
        # track of the original reference requested
        if(!versesNeeded.nil? && !versesNeeded.empty?)
            puts "Verses needed: #{versesNeeded.to_s}"
            versesNeeded.each do |verseToGet|
                url = bibleSearch.get_search_url(verseToGet)
                data = bibleSearch.get_search_result(url)

                puts "Retrieving from URL: " + url
                @passages = self.get_passages(data)

                # distill the verses from the results
                @passages.each_entry do |passage|
                    verse = self.distill(passage, verseToGet)
                    verses.push(verse)
                end

                # be nice: don't flood the service
                sleep(SLEEP_TIME)
            end
        end

        return verses
    end

    def check_for_verses(pack)
        # see if the verses are in db or if we need to fetch them
        versesNeeded = []
        pack.verses.each do |reference|
            @options[:translations].each do |translation|
                cache_key = translation.downcase + '::' + reference.downcase.gsub(/\s+/, "")

                curVerse = Verse.find_by_cache_key(cache_key)

                # if the verse is empty or we're overwriting it,
                # add it to the list to retrieve
                if curVerse.nil? || @options[:overwrite]
                    # puts "Needed: #{reference} (#{translation})"
                    versesNeeded.push(reference)
                end
            end
        end

        # We only want each reference once.
        # When we search, we grab results for all the translations desired.
        versesNeeded = versesNeeded.uniq

        return versesNeeded
    end

    def get_passages(data)
        # prepare to parse
        @doc = Nokogiri::XML(data) do |config|
            config.nocdata
        end

        # grab passages
        return @doc.css('passages passage')
    end

    def distill(passage, reference_requested)
        passage.css('sup').remove

        translation = passage.at_css('version').content
        reference = passage.at_css('display').content
        copyright = passage.at_css('copyright').content
        path = passage.at_css('path').content

        text = self.clean_text(passage.at_css('text').content)

        verse_options = {}
        if @options[:useMongo]
            verse_options = {
                'path' => path,
                'reference_requested' => reference_requested
            }
        end
        verse = self.create_verse(reference, text, translation, copyright, verse_options)
        return verse
    end

    def clean_text(passageText)
        text_html = Nokogiri::HTML(passageText)
        text_html.xpath("//sup").remove
        text_html.xpath("//h3").remove

        return self.cleanser(text_html.content)
    end

    def cleanser(text)
        coder = HTMLEntities.new

        # trim the leading/trailing whitespace, remove linebreaks,
        # remove tabs, remove excessive whitespace
        text = coder.encode(text)

        # keep strip on its own line because it returns nil when
        # there is no change to the string (and you can't chain it)
        text.strip!
        text.gsub!(/[\n\t]/, ' ')
        text.gsub!(/\s+/, " ")

        return text
    end

    def create_verse(reference, text, translation, copyright, verse_options = {})
        # this is where the verse factory could be handy
        settings = {
            :reference => reference,
            :text => text,
            :translation => translation,
            :copyright => copyright
        }
        if @options[:useMongo]
            # info needed to make retrieving from Mongo easier
            settings['reference_requested'] = verse_options['reference_requested']
            settings['path'] = verse_options['path']

            # TODO when using overwrite mode, check for existence of verse here
            # before writing to it, and if it's there, replace the old one.
            # As it is, we can end up with two copies of the same cache_key
            # (this can be worked around by setting
            # db.members.ensureIndex( { "cache_key": 1 }, { unique: true } )
            # in Mongo, but it isn't perfect and doesn't help us update the db.
            verse = Verse.create(settings)
            verse.save!
        else
            verse = VerseBase.new(settings)
        end
        return verse
    end
end
