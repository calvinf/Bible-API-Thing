#!/usr/bin/env ruby
require './api-key.rb' #loads BIBLE_KEY
require './models.rb'  #loads Pack and other models

require 'cgi'       #escaping
require 'curb'      #curl wrapper
require 'dalli'	    #memcached client
require 'nokogiri'  #xml parsing
require 'pp'        #prettyprint (for errors)

# globals
API_BASE = 'http://bibles.org/'
VERSIONS = 'ESV,KJV,NASB'

# http://bibles.org/pages/api/documentation/passages
# maximum of 3 returned verses for this api
PASSAGES_API = API_BASE + '/' + VERSIONS + '/passages.xml'

#memcached settings
MEMCACHE_SERVER      = 'localhost:11211'
MEMCACHE_PACK_PREFIX = 'tms-packs-'

def get_search_url(verse_reference)
  url = PASSAGES_API + '?&q[]=' + CGI.escape(verse_reference)
  return url 
end

def get_search_result(url)
  c = Curl::Easy.new(url)
  c.userpwd = BIBLE_KEY + ':X'
  c.perform
  return c.body_str
end

def print_passage(passage)
  version = passage.at_css('version').content
  ref     = passage.at_css('display').content
  text    = passage.at_css('text_preview').content

  puts "#{ref} (#{version}): #{text}"
end

#initialize dalli client
dc = Dalli::Client.new(MEMCACHE_SERVER) #default memcached port

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
  # retrieve pack from memcached if present
  mem_key = MEMCACHE_PACK_PREFIX + pack.get_title
  resp = dc.get(mem_key)

  if(resp.nil?)
    verse_string = pack.verses.join(',')
    url = get_search_url(verse_string)
    data = get_search_result(url)
    dc.set(mem_key, data)
  else
    data = resp
  end

  # prepare to parse
  @doc = Nokogiri::XML(data) do |config|
    config.nocdata
  end

  # grab passages
  @passages = @doc.css('passages passage')

  # print passages
  @passages.each_entry{|passage| print_passage(passage)}
end
