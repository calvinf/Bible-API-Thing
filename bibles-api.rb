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

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "versemachine"

class BibleApi
    def initialize

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

bibleApi = BibleApi.new()

#TMS specific stuff to refactor later
a = Pack.new('a')
b = Pack.new('b')
c = Pack.new('c')
d = Pack.new('d')
e = Pack.new('e')

#packs w/ arrays of bible verse references
a.verses = ["2 Corinthians 5:17", "Galatians 2:20", "Romans 12:1", "John 14:21", "2 Timothy 3:16", "Joshua 1:8", "John 15:7", "Philippians 4:6-7", "Matthew 18:20", "Hebrews 10:24-25", "Matthew 4:19", "Romans 1:16"]

b.verses = ["Romans 3:23", "Isaiah 53:6", "Romans 6:23", "Hebrews 9:27", "Romans 5:8", "1 Peter 3:18", "Ephesians 2:8-9", "Titus 3:5", "John 1:12", "Revelation 3:20", "1 John 5:13", "John 5:24"]

c.verses = ["1 Corinthians 3:16", "1 Corinthians 2:12", "Isaiah 41:10", "Philippians 4:13", "Lamentations 3:22-23", "Numbers 23:19", "Isaiah 26:3", "1 Peter 4:7", "Romans 8:32", "Philippians 4:19", "Hebrews 2:18", "Psalms 119:9-11"]

d.verses = ["Matthew 6:33", "Luke 9:23", "1 John 2:15-16", "Romans 12:2", "1 Corinthians 15:58", "Hebrews 12:3", "Mark 10:45", "2 Corinthians 4:5", "Proverbs 3:9-10", "2 Corinthians 9:6-7", "Acts 1:8", "Matthew 28:19-20"]

e.verses = ["John 13:34-35", "1 John 3:18", "Philippians 2:3-4", "1 Peter 5:5-6", "Ephesians 5:3", "1 Peter 2:11", "Leviticus 19:11", "Acts 24:16", "Hebrews 11:6", "Romans 4:20-21", "Galatians 6:9-10", "Matthew 5:16"]

packs = [a, b, c, d, e]

# loop through each pack
packs.each do |pack|
  bibleApi.get_pack_data(pack)
end
