#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# other includes
require './api-key.rb'		# BIBLE_KEY
require './BibleApi.rb'		# Bible API

api = BibleApi.new

if(ARGV.size < 1)
    print "Please pass in a file\n"
    exit
end

File.open(ARGV[0]) do |file|
    p = []
    file.readlines.each do |line|
        p.push(line.chomp)
    end

    versesWithPassage = api.get_verses(p)
    versesWithPassage.each do |passage|
        puts passage.text + "\n"
        puts passage.reference + "\n\n"
    end
    file.close
end
