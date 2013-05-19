require 'cgi'
require 'curb'
require_relative '../api-key.rb'

# http://bibles.org/pages/api/documentation/passages
# maximum of 3 returned verses for this api
API_BASE = 'http://bibles.org/v2/'

# http://bibles.org/pages/api/documentation/versions
# translations: comma separated list, e.g. 'eng-ESV,eng-KJV,eng-NASB'
VERSIONS = 'eng-ESV'

PASSAGES_API = API_BASE + '/' + VERSIONS + '/passages.xml'

class BibleSearch
    def initialize
        # TODO take a list of translations (search should use this instead of default)
    end

    # TODO move to BibleSearch class
    def get_search_url(verses)
        url = PASSAGES_API + '?&q[]=' + CGI.escape(verses.join(','))
        return url 
    end

    # TODO move to BibleSearch class
    def get_search_result(url)
        c = Curl::Easy.new(url)
        c.userpwd = BIBLE_KEY + ':X'
        c.perform
        return c.body_str
    end
end
