# Bible API Thing #

This is to interact with the BibleSearch API from the [American Bible Society](http://bibles.org/pages/api/).

As of May 19, 2013, Bible API Thing is compatible with [v2](http://bibles.org/pages/api/documentation/v2-migration) of the BibleSearch API.


## Components ##
BibleApi.rb is the main class - it contains the logic necessary to call the BibleSearch API and retrieve verses.

## Scripts ##
get-tms.rb
- Retrieves verses for the Topical Memory System

get-verses.rb
- Reads in a list of verse references from a file and prints them to the screen.  This can be handy for getting a list of verses and outputting them to a file.

## Database Options ##
Currently, verses can either be output to the screen or to MongoDB.  I'm looking at ways to make the database part of these tools more modular.


I create packs with a list of verses I want to retrieve.  The script checks for the presence of the pack in my memcached instance.  If it's there, I use it; otherwise, I make the call to the BibleSearch API and store it locally.

## Dependencies ##
### Gems ###

_The Gemfile will always have the current list, but here are a few._

To install bundler, run `gem install bundle`.  Once you have done this, you can run `bundle install` to install all gem dependencies for this library.

* [bson_ext](http://rubygems.org/gems/bson_ext)
* [bundler](http://rubygems.org/gems/bundler)
* [curb](http://rubygems.org/gems/curb)
* [htmlentities](http://rubygems.org/gems/htmlentities)
* [mongo_mapper](http://rubygems.org/gems/mongo_mapper)
* [nokogiri](http://rubygems.org/gems/nokogiri)
* [json](http://rubygems.org/gems/json)
