require 'cgi'
require 'curb'
require_relative '../api-key.rb'

class BibleSearch
    attr_accessor :versions

    # http://bibles.org/pages/api/documentation/passages
    # maximum of 3 returned verses for this api
    API_BASE = 'http://bibles.org/v2/'

    # http://bibles.org/pages/api/documentation/versions
    # translations: comma separated list, e.g. 'eng-ESV,eng-KJV,eng-NASB'
    DEFAULT_VERSIONS = ['eng-ESV']

    def initialize(versions)
        @versions = versions ? versions : DEFAULT_VERSIONS
    end

    def get_search_url(verses)
        url = get_passages_url + '?&q[]=' + CGI.escape(verses.join(','))
        return url 
    end

    def get_passages_url
        return API_BASE + '/' + @versions.join(',') + '/passages.xml'
    end

    def get_search_result(url)
        c = Curl::Easy.new(url)
        c.userpwd = BIBLE_KEY + ':X'
        c.perform
        return c.body_str
    end
end
