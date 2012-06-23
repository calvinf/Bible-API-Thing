# globals
API_BASE = 'http://bibles.org/'

# translations: comma separated list, e.g. 'ESV,KJV,NASB'
VERSIONS = 'ESV'

# http://bibles.org/pages/api/documentation/passages
# maximum of 3 returned verses for this api
PASSAGES_API = API_BASE + '/' + VERSIONS + '/passages.xml'

# memcached settings
MEMCACHE_SERVER      = 'localhost:11211'
MEMCACHE_PREFIX = 'tms-' + VERSIONS.downcase
