#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require './api-key.rb' # BIBLE_KEY
require './models/BibleSearch.rb' # Bible Search
require './models/Records.rb' # ActiveRecord initialization
require './models/Verse.rb' # Verse model

class BibleApi
    # Constants
    # amount of time to sleep between API calls
    SLEEP_TIME = 0.1

    def initialize(opts = {})
        @options = {
            :overwrite => false,
            :translations => ['eng-ESV']
        }.merge(opts)
    end

    def get_verses(verseList, title="current list")
        # determine verses needed
        versesNeeded = get_verses_needed(verseList, title)

        # get the verses
        verses = fetch_verses(versesNeeded, title)
        return verses
    end

    # methods below here are private
    private

    def get_verses_needed(verseList, title)
        versesNeeded = check_for_verses(verseList)

        if versesNeeded.length == 0
            puts "#{title}: all verses found."
            return
        end

        puts "Verses needed for #{title}: #{versesNeeded.to_s}"
        return versesNeeded
    end

    def fetch_verses(versesNeeded, title)
        # array of resulting verses
        verses = []

        bibleSearch = BibleSearch.new(@options[:translations])

        # TODO find a way to minize API calls and still keep
        # track of the original reference requested
        if(!versesNeeded.nil? && !versesNeeded.empty?)
            versesNeeded.each do |verseToGet|
                url = bibleSearch.get_search_url(verseToGet)
                data = bibleSearch.get_search_result(url)

                puts "Retrieving from URL: " + url
                @passages = get_passages(data)

                # distill the verses from the results
                @passages.each_entry do |passage|
                    verse = distill(passage, verseToGet)
                    verses.push(verse)
                end

                # be nice: don't flood the service
                sleep(SLEEP_TIME)
            end
        end

        return verses
    end

    def check_for_verses(verseList)
        # see if the verses are in db or if we need to fetch them
        versesNeeded = []
        verseList.each do |reference|
            @options[:translations].each do |translation|
                verse_key = translation.downcase + '::' + reference.downcase.gsub(/\s+/, "")

                curVerse = Verse.find_by(verse_key: verse_key)

                # if the verse is empty or we're overwriting it,
                # add it to the list to retrieve
                if curVerse.nil? || @options[:overwrite]
                    puts "Needed: #{reference} (#{translation})"
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

        text = clean_text(passage.at_css('text').content)

        verse_options = {
            reference: reference,
            text: text,
            translation: translation,
            copyright: copyright,
            path: path,
            reference_requested: reference_requested
        }

        verse = create_verse(verse_options)
        return verse
    end

    def clean_text(passageText)
        text_html = Nokogiri::HTML(passageText)
        text_html.xpath("//sup").remove
        text_html.xpath("//h3").remove

        return cleanser(text_html.content)
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

    def create_verse(verse_options)
        settings = verse_options
        settings[:verse_key] = "#{settings[:translation].downcase}::#{settings[:reference_requested].downcase.gsub(/\s+/, "")}"

        # TODO when using overwrite mode, check for existence of verse here
        # before writing to it, and if it's there, replace the old one.
        # As it is, we can end up with two copies of the same verse_key.

        verse = Verse.create(settings)
        verse.save!

        return verse
    end
end
