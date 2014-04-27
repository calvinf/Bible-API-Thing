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
    def initialize(opts = {})
        @options = {
            :useMongo => true,
            :translations => ['eng-ESV']
        }.merge(opts)

        if @options[:useMongo]
            # TODO add error handling when server is unreachable
            # here and elsewhere in file
            MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
            MongoMapper.database = "versemachine"
        end
    end

    def get_pack_data(pack)
        bibleSearch = BibleSearch.new(@options[:translations])

        # by default, get all verses
        versesNeeded = pack.verses

        if @options[:useMongo]
            # only get the verses we don't already have in Mongo
            versesNeeded = self.check_for_verses(pack)
            if versesNeeded.length == 0
                puts "Pack #{pack.get_title}: all verses found in MongoDB"
                return
            end
        end

        puts "Verses needed for #{pack.get_title}: #{versesNeeded.to_s}"
        url = bibleSearch.get_search_url(versesNeeded)
        data = bibleSearch.get_search_result(url)

        puts "Retrieving from URL: " + url

        @passages = self.get_passages(data)

        # distill the verses from the results
        verses = []
        @passages.each_entry do |passage|
            verses.push( self.distill(passage) )
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
                if curVerse.nil?
                    versesNeeded.push(reference)
                end
            end
        end

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

    def distill(passage)
        passage.css('sup').remove

        translation = passage.at_css('version').content
        reference   = passage.at_css('display').content

        text_html = Nokogiri::HTML(passage.at_css('text').content)
        text_html.xpath("//sup").remove
        text_html.xpath("//h3").remove

        text  = self.cleanser(text_html.content)
        verse = self.create_verse(reference, text, translation)
        return verse
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

    def create_verse(reference, text, translation)
        # this is where the verse factory could be handy
        settings = {
            :reference => reference, 
            :text => text, 
            :translation => translation
        }
        if @options[:useMongo]
            verse = Verse.create(settings)
            verse.save!
        else
            verse = VerseBase.new(settings)
        end
        return verse
    end
end
