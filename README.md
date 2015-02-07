# Bible API Thing #

Bible API Thing helps query information from the BibleSearch API from the [American Bible Society](http://bibles.org/pages/api/), and store the resulting data in a relational database for usage on a website or in other software.

Bible API Thing uses [v2](http://bibles.org/pages/api/documentation/v2-migration) of the BibleSearch API.

## Components ##
BibleApi.rb is the main class - it contains the logic necessary to call the BibleSearch API and retrieve verses.

## Scripts ##
get-tms.rb
- Retrieves verses for the Topical Memory System

get-verses.rb
- Reads in a list of verse references from a file and prints them to the screen.  This can be handy for getting a list of verses and outputting them to a file.

## Database Options ##

In the newest version of Bible-API-Thing, we're switching to an ActiveRecord for ORM to allow more flexibility in the types of databases the data can be stored in.  Because the data is well structured, a NoSQL database is not necessary and puts limitations on how simply the data can be used.  MongoDB also lacks features such as selecting a random entry from a query result set.

I create packs with a list of verses I want to retrieve.  The script checks for the presence of the pack in my MongoDB instance.  If it's there, I use it; otherwise, I make the call to the BibleSearch API and store it locally.  Note: Bible API has restrictions around storage of data -- please abide by these rules, and include appropriate copyright and usage tracking information in your website if you use data from the API.

## Dependencies ##
### Gems ###

_The Gemfile will always have the current list, but here are a few._

To install bundler, run `gem install bundle`.  Once you have done this, you can run `bundle install` to install all gem dependencies for this library.

* [activemodel](https://rubygems.org/gems/activemodel)
* [activerecord](https://rubygems.org/gems/activerecord)
* [bson_ext](http://rubygems.org/gems/bson_ext)
* [bundler](http://rubygems.org/gems/bundler)
* [curb](http://rubygems.org/gems/curb)
* [htmlentities](http://rubygems.org/gems/htmlentities)
* [nokogiri](http://rubygems.org/gems/nokogiri)
* [json](http://rubygems.org/gems/json)
