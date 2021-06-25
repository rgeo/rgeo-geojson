# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/rgeo-geojson"

class GeometryUsageTest < Minitest::Test # :nodoc:
  def setup
    @geo_factory = RGeo::Cartesian.factory
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
    assert_equal(
      rgeo_feature.as_text,
      rgeo_feature.geometry.as_text
    )
  end

  def test_collection_contains?
    skip "`#contains?` is not defined in pure ruby" unless RGeo::Geos.capi_supported?

    collection = polygon_and_point_collection

    assert collection.contains? @geo_factory.point(5.0, 6.0)
  end

  def test_collection_intersects?
    skip "`#intersects?`` is not defined in pure ruby" unless RGeo::Geos.capi_supported?

    collection = polygon_and_point_collection

    assert collection.intersects? @geo_factory.point(5.0, 6.0)
  end

  private

  def polygon_and_point_collection
    RGeo::GeoJSON.decode({
      "type" => "FeatureCollection",
      "features" => [
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Point",
            "coordinates" => [10.0, 20.0],
          },
          "properties" => {},
        },
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[[0.0, 0.0], [10.0, 10.0], [0.0, 10.0], [0.0, 0.0]]],
          },
          "properties" => {},
        }
      ]
    }, geo_factory: @geo_factory)
  end
end
