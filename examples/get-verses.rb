#!/usr/bin/env ruby

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
        'eng-NIV', # New International Version
        'eng-NLT', # New Living Translation
        'eng-NASB', # New American Standard Bible
        'spa-RVR1960', # Biblia Reina Valera 1960
        'vie-RVV11' # Revised Vietnamese Version Bible
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
