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
a = ["2 Corinthians 5:17", "Galatians 2:20", "Romans 12:1", "John 14:21", "2 Timothy 3:16", "Joshua 1:8", "John 15:7", "Philippians 4:6-7", "Matthew 18:20", "Hebrews 10:24-25", "Matthew 4:19", "Romans 1:16"]
api.get_verses(a, "A")

b = ["Romans 3:23", "Isaiah 53:6", "Romans 6:23", "Hebrews 9:27", "Romans 5:8", "1 Peter 3:18", "Ephesians 2:8-9", "Titus 3:5", "John 1:12", "Revelation 3:20", "1 John 5:13", "John 5:24"]
api.get_verses(b, "B")

c = ["1 Corinthians 3:16", "1 Corinthians 2:12", "Isaiah 41:10", "Philippians 4:13", "Lamentations 3:22-23", "Numbers 23:19", "Isaiah 26:3", "1 Peter 4:7", "Romans 8:32", "Philippians 4:19", "Hebrews 2:18", "Psalm 119:9-11"]
api.get_verses(c, "C")

d = ["Matthew 6:33", "Luke 9:23", "1 John 2:15-16", "Romans 12:2", "1 Corinthians 15:58", "Hebrews 12:3", "Mark 10:45", "2 Corinthians 4:5", "Proverbs 3:9-10", "2 Corinthians 9:6-7", "Acts 1:8", "Matthew 28:19-20"]
api.get_verses(d, "D")

e = ["John 13:34-35", "1 John 3:18", "Philippians 2:3-4", "1 Peter 5:5-6", "Ephesians 5:3", "1 Peter 2:11", "Leviticus 19:11", "Acts 24:16", "Hebrews 11:6", "Romans 4:20-21", "Galatians 6:9-10", "Matthew 5:16"]
api.get_verses(e, "E")
