#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# all the other things we want to use
require 'cgi' # escaping
require 'pp'  # prettyprint (for errors and testing)

# other includes
require './api-key.rb'		  # BIBLE_KEY
require './models/BibleSearch.rb' # Bible Search
require './models/Pack.rb'	  # Pack model

#TODO look adding this method to pack
def get_pack_data(pack)
    bibleSearch = BibleSearch.new

    puts "Verses needed for #{pack.get_title}"
    url      = bibleSearch.get_search_url(pack.verses)
    data     = bibleSearch.get_search_result(url)
    passages = get_passages(data)

    verses = []
    passages.each do |passage|
	verses.push(distill(passage))
    end
    return verses
end

def get_passages(data)
    # prepare to parse
    # print data
    doc = Nokogiri::XML(data) 
    @passages =  doc.css('passages passage')

    # grab passages
    return @passages
end

def distill(passage)
    coder = HTMLEntities.new

    passage.css('sup').remove
    
    translation = passage.at_css('version').content
    reference   = passage.at_css('display').content

    text_html = Nokogiri::HTML(passage.at_css('text_preview').content)
    text_html.xpath("//sup").remove

    #trim the leading/trailing whitespace, remove linebreaks, remove tabs, remove excessive whitespace
    text = text_html.content
    text = coder.encode(text)
    text.strip!.gsub!(/[\n\t]/, ' ')
    text.gsub!(/\s+/, " ")

    verse = {
	:reference => reference, 
	:text => text, 
	:translation => translation
    }

    return verse
end

if(ARGV.size < 1) 
    print "Please pass in a file\n"
    exit
end

File.open(ARGV[0]) do |file| 
    p = Pack.new("prayer")
    p.verses = file.readlines

    versesWithPassage = get_pack_data(p)
    versesWithPassage.each do |passage|
	puts passage[:text]+"\n"
	puts passage[:reference]+"\n\n"
    end	
    file.close
end
