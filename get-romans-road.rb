#!/usr/bin/env ruby

# using bundler http://gembundler.com/
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# for options parsing
require 'optparse'

# other includes
require './api-key.rb'		# BIBLE_KEY
require './models/Pack.rb'	# Pack model
require './BibleApi.rb'	    # Bible API

# Setup BibleApi to take options for Mongo connection
options = {
    :useMongo => true,
    :overwrite => false,

    # Recommendation: TMS has verses in both OT & NT. Pick translations with both.
    :translations => [
        'eng-CEV',
        'eng-ESV', # English Standard Version
        'eng-KJV', # King James Version
        'eng-MSG',
        'eng-NASB'
    ]
}

# we want to allow some options for this file such as
# the ability to overwrite existing verses in the db
# in cases where we have changed the verse model,
# or need additional information from the API
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: $0 [options]"

    opts.on( '-o', '--overwrite', 'Optional: replace and overwrite existing verses' ) do |overwrite|
        options[:overwrite] = true
    end

    opts.on( '-h', '--help', 'Display help screen' ) do
        puts opts
        exit
    end
end

optparse.parse!

# Roman's Road
road = Pack.new('Roman\'s Road')
road.verses = [
    "Romans 3:10",
    "Romans 3:23",
    "Romans 5:8",
    "Romans 5:12",
    "Romans 6:23",
    "Romans 10:9-11",
    "Romans 10:13"
]

bibleApi = BibleApi.new(options)
bibleApi.get_pack_data(road)
