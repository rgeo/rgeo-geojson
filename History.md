### Ongoing

* Delegation to inner geometry for a feature (#53)
* MultiJson rather than JSON (#46)

### 2.1.1 / 2018-11-27

* Freeze strings


### 2.1.0 / 2018-11-27

* Allow rgeo 2.0
* Require ruby 2.3+


### 2.0.0 / 2018-01-13

* Remove :json_parser option #38
  * Use stdlib JSON parser


### 1.0.0 / 2017-12-02

* Require ruby 2.1+
* Require rgeo 1.0+ #36


### 0.4.2 / 2016-01-05

* Fix Feature#inspect #21


### 0.4.1 / 2015-12-29

* Restore rgeo/geo_json.rb


### 0.4.0 / 2015-12-28

* Remove error handling for missing parser gems
* Remove class variables in Coder
* Remove rgeo/geo_json.rb


### 0.3.3 / 2015-12-23

* Rubocop style updates #20
* Do not distribute test files with gem


### 0.3.2 / 2015-12-10

* Faster coordinates methods (tneems) #18
* Require rgeo 0.5.0+


### 0.3.1 / 2014-05-29

* Include docs files in gemspec
* Gemspec cleanup


### 0.3.0 / 2014-05-27

* Require ruby 1.9.3+
* Update development environment


### 0.2.5 / 2012-??-??

* The gemspec no longer includes the timestamp in the version, so that
  bundler can pull from github. (Reported by corneverbruggen)


### 0.2.4 / 2012-04-??

* Travis CI integration.


### 0.2.3 / 2012-03-17

* Returns nil from the encode method if nil is passed in. (Suggestion by
  Pete Deffendol.)


### 0.2.2 / 2012-01-09

* Fixed Feature#property(:symbol). (Reported by Andy Allan.)
* Added an "rgeo-geojson.rb" wrapper so bundler's auto-require will work
  without modification. (Reported by Mauricio Pasquier Juan.)


### 0.2.1 / 2011-04-11

* The gem version is now accessible via an api.
* A .gemspec file is now available for gem building and bundler git
  integration.


### 0.2.0 / 2010-12-07

* Initial public alpha release. Spun rgeo-geojson off from the core rgeo
  gem.


For earlier history, see the History file for the rgeo gem.
