#!/usr/bin/env ruby

# for options parsing
require 'optparse'

# other includes
require_relative '../BibleApi.rb'

# Setup BibleApi to take options
options = {
    :encode => false,
    :overwrite => false,

    # Recommendation: TMS has verses in both OT & NT. Pick translations with both.
    :translations => [
        'eng-CEV', # Contemporary English Version
        'eng-ESV', # English Standard Version
        'eng-KJV', # King James Version
        'eng-MSG', # The Message
        'eng-NASB', # New American Standard Bible
        'spa-RVR1960' # Biblia Reina Valera 1960
    ]
}

# we want to allow some options for this file such as
# the ability to overwrite existing verses in the db
# in cases where we have changed the verse model,
# or need additional information from the API
optparse = OptionParser.new do |opts|
    opts.banner = "Usage: $0 [options]"

    opts.on( '-o', '--overwrite', 'Optional: replace and overwrite existing verses' ) do
        options[:overwrite] = true
    end

    opts.on( '--encode', 'Optional: enable HTML encoding of output content' ) do
        options[:encode] = true
    end

    opts.on( '-h', '--help', 'Display help screen' ) do
        puts opts
        exit
    end
end

optparse.parse!

api = BibleApi.new(options)

# packs w/ arrays of bible verse references
rr = [
  "Romans 3:10",
  "Romans 3:23",
  "Romans 5:8",
  "Romans 5:12",
  "Romans 6:23",
  "Romans 10:9-11",
  "Romans 10:13",
]

api.get_verses(rr, "Roman's Road")
