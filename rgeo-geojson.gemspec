require "./lib/rgeo/geo_json/version"

Gem::Specification.new do |spec|
  spec.name = "rgeo-geojson"
  spec.summary = "Convert RGeo data to and from GeoJSON."
  spec.description =
    "Convert RGeo data to and from GeoJSON. "\
    "rgeo-geojson is an extension to the rgeo gem that converts "\
    "RGeo data types to and from GeoJSON."

  spec.authors = ["Daniel Azuma", "Tee Parham"]
  spec.email = ["dazuma@gmail.com", "parhameter@gmail.com", "kfdoggett@gmail.com"]
  spec.homepage = "https://github.com/rgeo/rgeo-geojson"
  spec.license = "BSD-3-Clause"

  spec.files = Dir["lib/**/*.rb", "*.md", "LICENSE.txt"]

  spec.version = RGeo::GeoJSON::VERSION

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "rgeo", ">= 1.0.0"
  spec.add_dependency "multi_json", "~> 1.15"

  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "rake", "~> 12.0"
end
