# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/rgeo-geojson"
require_relative "../common/conversion_test"

class CartesianConversionTest < Minitest::Test # :nodoc:
  include RGeo::GeoJSON::Tests::Common::ConversionTests

  def setup
    @factory = RGeo::Cartesian.simple_factory
  end
end
