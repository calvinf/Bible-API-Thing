#!/usr/bin/env ruby
require './api-key.rb' #loads BIBLE_KEY

require 'cgi'
require 'curb'
#require 'json'

# globals
API_BASE = 'http://bibles.org/'
VERSIONS = 'ESV,KJV,NASB'
SEARCH_API = API_BASE + '/' + VERSIONS + '/passages.js'

def get_search_url(verse_reference)
  url = SEARCH_API + '?&q[]=' + CGI.escape(verse_reference)
  return url 
end

def get_search_result(url)
  c = Curl::Easy.new(url)
  c.userpwd = BIBLE_KEY + ':X'
  c.perform
  puts c.body_str
end

#TMS specific stuff to refactor later
packs = %w{a b c d e}
verses_per_pack = 12

#packs w/ arrays of bible verse references
a = ["2 Corinthians 5:17", "Galatians 2:20", "Romans 12:1", "John 14:21", "2 Timothy 3:16", "Joshua 1:8", "John 15:7", "Philippians 4:6-7", "Matthew 18:20", "Hebrews 10:24-25", "Matthew 4:19", "Romans 1:16"]
b = []
c = []
d = []
e = []

url = get_search_url(a[0])
puts "URL: " + url

get_search_result(url)
