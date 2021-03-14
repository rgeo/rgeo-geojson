# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/rgeo-geojson"

class GeometryUsageTest < Minitest::Test # :nodoc:
  def setup
    @geo_factory = RGeo::Cartesian.simple_factory
  end

  def test_feature_uses_method_missing
    json = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Polygon",
        "coordinates" => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0], [10.0, 20.0]]]
      }
    }
    rgeo_feature = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    pt = @geo_factory.point([10.0, 14.0].sample, [20.0, 25.0].sample)

    assert_equal(
      rgeo_feature.contains?(pt),
      rgeo_feature.geometry.contains?(pt)
    )
  end

  def test_feature_collection_uses_method_missing
    json = {
      "type" => "FeatureCollection",
      "features" => [
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0], [10.0, 20.0]]],
          },
          "properties" => {},
        }
      ]
    }
    rgeo_feature_collection = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    pt = @geo_factory.point([10.0, 14.0].sample, [20.0, 25.0].sample)
    assert_equal(
      rgeo_feature_collection.as_text,
      rgeo_feature_collection.geometry.as_text
    )
  end
end
