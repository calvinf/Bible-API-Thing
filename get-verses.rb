#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# all the other things we want to use
require 'pp' # prettyprint (for errors and testing)

# other includes
require './api-key.rb'		# BIBLE_KEY
require './BibleApi.rb'		# Bible API
require './models/Pack.rb'	# Pack model

bibleApi = BibleApi.new

if(ARGV.size < 1) 
    print "Please pass in a file\n"
    exit
end

File.open(ARGV[0]) do |file| 
    p = Pack.new("prayer")
    p.verses = file.readlines

    versesWithPassage = bibleApi.get_pack_data(p)
    versesWithPassage.each do |passage|
        puts passage.text + "\n"
        puts passage.reference + "\n\n"
    end	
    file.close
end
