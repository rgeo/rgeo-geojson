require "./lib/rgeo/geo_json/version"

Gem::Specification.new do |spec|
  spec.name = "rgeo-geojson"
  spec.summary = "Convert RGeo data to and from GeoJSON."
  spec.description =
    "Convert RGeo data to and from GeoJSON. "\
    "rgeo-geojson is an extension to the rgeo gem that converts "\
    "RGeo data types to and from GeoJSON."

  spec.authors = ["Daniel Azuma", "Tee Parham"]
  spec.email = ["dazuma@gmail.com", "parhameter@gmail.com"]
  spec.homepage = "https://github.com/rgeo/rgeo-geojson"
  spec.license = "BSD"
  spec.platform = Gem::Platform::RUBY

  spec.files = Dir["lib/**/*.rb", "*.md", "LICENSE.txt"]

  spec.version = RGeo::GeoJSON::VERSION

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_dependency "rgeo", "~> 0.5"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "rake", "~> 12.0"
end
