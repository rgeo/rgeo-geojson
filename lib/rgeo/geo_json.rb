require 'rgeo'


# RGeo is a spatial data library for Ruby, provided by the "rgeo" gem.
#
# The optional RGeo::GeoJSON module provides a set of tools for GeoJSON
# encoding and decoding.

module RGeo


  # This is a namespace for a set of tools that provide GeoJSON encoding.
  # See http://geojson.org/ for more information about this specification.

  module GeoJSON
  end


end


# Implementation files
require 'rgeo/geo_json/version'
require 'rgeo/geo_json/entities'
require 'rgeo/geo_json/coder'
require 'rgeo/geo_json/interface'
