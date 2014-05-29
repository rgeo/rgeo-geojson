require './lib/rgeo/geo_json/version'

Gem::Specification.new do |spec|
  spec.name = 'rgeo-geojson'
  spec.summary = 'An RGeo module providing GeoJSON encoding and decoding.'
  spec.description = "RGeo is a geospatial data library for Ruby. RGeo::GeoJSON is an optional RGeo module providing GeoJSON encoding and decoding services. This module can be used to communicate with location-based web services that understand the GeoJSON format."
  spec.authors = ['Daniel Azuma', 'Tee Parham']
  spec.email = ['dazuma@gmail.com', 'parhameter@gmail.com']
  spec.homepage = "http://github.com/rgeo/rgeo-geojson"
  spec.license = 'BSD'
  spec.platform = Gem::Platform::RUBY

  spec.files = Dir["lib/**/*.rb", "test/**/*.rb", "*.md", "LICENSE.txt"]
  spec.test_files = Dir["test/**/*_test.rb"]

  spec.version = RGeo::GeoJSON::VERSION

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'rgeo', '~> 0.3'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'minitest', '~> 5.3'
  spec.add_development_dependency 'rake', '~> 10.3'
end
