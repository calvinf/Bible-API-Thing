#!/usr/bin/env ruby

require 'optparse'

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# other includes
require './api-key.rb'		    # BIBLE_KEY
require './models/Pack.rb'	    # Pack model
require './BibleApi.rb'	    # Bible API

options = {}

optparse = OptionParser.new do |opts|
    opts.banner = "Usage: $0 [options] file"

    options[:name] = nil
    opts.on( '-n', '--name NAME', 'Required: set the pack name' ) do |name|
        options[:name] = name || "nothing"
    end

    opts.on( '-h', '--help', 'Display help screen' ) do
        puts opts
        exit
    end
end

optparse.parse!

if options[:name].nil?
    puts "Required: --name NAME\n"
    exit
end

# Setup BibleApi to take options for Mongo connection
bibleApiOpts = {
    :useMongo => true
}
bibleApi = BibleApi.new(bibleApiOpts)

if(ARGV.size < 1) 
    print "Please pass in a file\n"
    exit
end

if(ARGV.size > 1)
    print "Please send in one file at a time\n"
    exit
end

File.open(ARGV[0]) do |file| 
    pack = Pack.new(options[:name])
    verses = []
    file.readlines.each do |line|
        verses.push(line.chomp)
    end
    pack.verses = verses

    bibleApi.get_pack_data(pack)
end
