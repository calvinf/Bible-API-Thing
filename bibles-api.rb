#!/usr/bin/env ruby
require './api-key.rb' #loads BIBLE_KEY

require 'cgi'
require 'curb'
require 'json'

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
b = ["Romans 3:23", "Isaiah 53:6", "Romans 6:23", "Hebrews 9:27", "Romans 5:8", "1 Peter 3:18", "Ephesians 2:8-9", "Titus 3:5", "John 1:12", "Revelation 3:20", "1 John 5:13", "John 5:24"]
c = ["1 Corinthians 3:16", "1 Corinthians 2:12", "Isaiah 41:10", "Philippians 4:13", "Lamentations 3:22-23", "Numbers 23:19", "Isaiah 26:3", "1 Peter 4:7", "Romans 8:32", "Philippians 4:19", "Hebrews 2:18", "Psalms 119:9-11"]
d = ["Matthew 6:33", "Luke 9:23", "1 John 2:15-16", "Romans 12:2", "1 Corinthians 15:58", "Hebrews 12:3", "Mark 10:45", "2 Corinthians 4:5", "Proverbs 3:9-10", "2 Corinthians 9:6-7", "Acts 1:8", "Matthew 28:19-20"]
e = ["John 13:34-35", "1 John 3:18", "Philippians 2:3-4", "1 Peter 5:5-6", "Ephesians 5:3", "1 Peter 2:11", "Leviticus 19:11", "Acts 24:16", "Hebrews 11:6", "Romans 4:20-21", "Galatians 6:9-10", "Matthew 5:16"]

full_pack_list = [a,b,c,d,e].join(',')

url = get_search_url(full_pack_list)
get_search_result(url)
