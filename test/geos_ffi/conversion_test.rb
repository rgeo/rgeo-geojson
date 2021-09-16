# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/rgeo-geojson"
require_relative "../common/conversion_test"

class GeosFFIConversionTest < Minitest::Test # :nodoc:
  include RGeo::GeoJSON::Tests::Common::ConversionTests

  def setup
    @factory = RGeo::Geos.factory(native_interface: :ffi)
  end
end
