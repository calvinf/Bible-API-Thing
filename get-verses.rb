#!/usr/bin/env ruby

# using bundler up in here, up in here
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# all the other things we want to use
require 'cgi' #escaping
require 'pp'  #prettyprint (for errors and testing)

# other includes
require './api-key.rb'		# BIBLE_KEY
require './config.rb'		# configuration
require './models/Pack.rb'	# Pack model

# TODO move to BibleSearch class
def get_search_url(verses)
    url = PASSAGES_API + '?&q[]=' + CGI.escape(verses.join(','))
    return url 
end

# TODO move to BibleSearch class
def get_search_result(url)
    c = Curl::Easy.new(url)
    c.userpwd = BIBLE_KEY + ':X'
    c.perform
    return c.body_str
end

#TODO look adding this method to pack
def get_pack_data(pack)
	puts "Verses needed for #{pack.get_title}"
	url       = get_search_url(pack.verses)
	data      = get_search_result(url)
	passages = get_passages(data)
	
	verses = [];
	passages.each do |passage|
		verses.push(distill(passage))
		#puts verse.to_s
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
    #puts verse.to_s

    return verse
end

if(ARGV.size < 1) 
	print "Please pass in a file\n"
	exit
end

File.open(ARGV[0]) do |file| 
	p = Pack.new("prayer")
	p.verses = file.readlines
	#puts p.to_s
	versesWithPassage = get_pack_data(p)
	versesWithPassage.each do |passage|
		puts passage[:text]+"\n"
		puts passage[:reference]+"\n\n"
	end	
	file.close
end
