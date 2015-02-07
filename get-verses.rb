#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# other includes
require './api-key.rb'		# BIBLE_KEY
require './BibleApi.rb'		# Bible API

bibleApi = BibleApi.new

if(ARGV.size < 1)
    print "Please pass in a file\n"
    exit
end

File.open(ARGV[0]) do |file|
    p = {title: "Verse Script", verses: []}
    file.readlines.each do |line|
        p[:verses].push(line.chomp)
    end

    versesWithPassage = bibleApi.get_pack_data(p)
    versesWithPassage.each do |passage|
        puts passage.text + "\n"
        puts passage.reference + "\n\n"
    end
    file.close
end
