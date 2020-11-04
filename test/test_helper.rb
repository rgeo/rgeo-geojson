# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/rgeo-geojson"

module TestHelper
  def rand_lng_lat
    [rand(-180.0..180.0).round(5), rand(-90.0..90.0).round(5)]
  end

  def rand_point
    @geo_factory.point(*rand_lng_lat)
  end

  def rand_linestring(size = 2)
    @geo_factory.line_string(Array.new(size) { rand_point })
  end
end
