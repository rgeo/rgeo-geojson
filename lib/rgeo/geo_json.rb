# frozen_string_literal: true

require "multi_json"
require "rgeo"

module RGeo
  module GeoJSON
    class Error < RGeo::Error::RGeoError
    end
  end
end

require_relative "geo_json/version"
require_relative "geo_json/entities"
require_relative "geo_json/coder"
require_relative "geo_json/interface"
