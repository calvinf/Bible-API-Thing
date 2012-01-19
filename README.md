# Bible API Thing #

This is to interact with the BibleSearch API from the [American Bible Society](http://bibles.org/pages/api/).

## Note: In Progress ##

I create packs with a list of verses I want to retrieve.  The script checks for the presence of the pack in my memcached instance.  If it's there, I use it; otherwise, I make the call to the BibleSearch API and store it locally.

## Dependencies ##
### Gems ###

_The Gemfile will always have the current list._

* [bundler](http://rubygems.org/gems/bundler)
* [curb](http://rubygems.org/gems/curb)
* [dalli](http://rubygems.org/gems/dalli)
* [nokogiri](http://rubygems.org/gems/nokogiri)

