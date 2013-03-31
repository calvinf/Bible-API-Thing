#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# all the other things we want to use
require 'pp'  # prettyprint (for errors and testing)

# other includes
require './api-key.rb'		    # BIBLE_KEY
require './models/Pack.rb'	    # Pack model
require './models/Verse.rb'	    # Verse model
require './models/BibleSearch.rb'   # Bible Search

class BibleApi
    def initialize(useMongo = true)
	if useMongo
	    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
	    MongoMapper.database = "versemachine"
	end
    end

    #TODO look adding this method to pack
    def get_pack_data(pack)
	bibleSearch = BibleSearch.new()
	versesNeeded = self.check_for_verses(pack)

	if versesNeeded > 0
	    puts "Verses needed for #{pack.get_title}"
	    url       = bibleSearch.get_search_url(pack.verses)
	    data      = bibleSearch.get_search_result(url)
	    @passages = self.get_passages(data)

	    # print passages
	    @passages.each_entry do |passage|
		verse = self.distill(passage)
	    end
	else
	    puts "Pack #{pack.get_title}: all verses found in MongoDB"
	end
    end

    def check_for_verses(pack)
	# see if the verses are in db or if we need to fetch them
	versesNeeded = 0
	pack.verses.each do |reference|
	    cache_key = 'esv::' + reference.downcase.gsub(/\s+/, "")
	    curVerse = Verse.find_by_cache_key(cache_key)
	    if curVerse.nil?
		versesNeeded += 1
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
	coder = HTMLEntities.new

	passage.css('sup').remove
	
	translation = passage.at_css('version').content
	reference   = passage.at_css('display').content

	text_html = Nokogiri::HTML(passage.at_css('text_preview').content)
	text_html.xpath("//sup").remove

	# trim the leading/trailing whitespace, remove linebreaks, 
	# remove tabs, remove excessive whitespace
	text = text_html.content
	text = coder.encode(text)
	text.strip!.gsub!(/[\n\t]/, ' ')
	text.gsub!(/\s+/, " ")

	verse = self.create_verse(reference, text, translation)
	puts verse.to_s
	return verse
    end

    def create_verse(reference, text, translation)
	verse = Verse.create({
	    :reference => reference, 
	    :text => text, 
	    :translation => translation
	})
	verse.save!
	return verse
    end
end
