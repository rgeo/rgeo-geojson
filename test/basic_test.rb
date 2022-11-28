# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/rgeo-geojson"
class BasicTest < Minitest::Test # :nodoc:
  def setup
    ruby_wkt_opts = { convert_case: :upper }
    @geo_factory = RGeo::Cartesian.simple_factory(srid: 4326, wkt_generator: ruby_wkt_opts)
    @geo_factory_z = RGeo::Cartesian.simple_factory(srid: 4326, has_z_coordinate: true)
    @geo_factory_m = RGeo::Cartesian.simple_factory(srid: 4326, has_m_coordinate: true)
    @geo_factory_zm = RGeo::Cartesian.simple_factory(srid: 4326, has_z_coordinate: true, has_m_coordinate: true)
    @entity_factory = RGeo::GeoJSON::EntityFactory.instance
  end

  def test_has_version
    refute_nil(RGeo::GeoJSON::VERSION)
  end

  def test_nil
    assert_nil(RGeo::GeoJSON.encode(nil))
    assert_nil(RGeo::GeoJSON.decode(nil, geo_factory: @geo_factory))
  end

  def test_decode_simple_point
    json = %({"type":"Point","coordinates":[1,2]})
    point = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    assert_equal "POINT (1.0 2.0)", point.as_text
  end

  def test_decode_point
    json = '{"type":"Feature","geometry":{"type":"Point","coordinates":[2.5,4.0]},"properties":{"color":"red"}}'
    feature = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    assert_equal "red", feature["color"]
    assert_equal "POINT (2.5 4.0)", feature.geometry.as_text
  end

  def test_point
    object = @geo_factory.point(10, 20)
    json = {
      "type" => "Point",
      "coordinates" => [10.0, 20.0],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_point_z
    object = @geo_factory_z.point(10, 20, -1)
    json = {
      "type" => "Point",
      "coordinates" => [10.0, 20.0, -1.0],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory_z).eql?(object))
  end

  def test_point_m
    object = @geo_factory_m.point(10, 20, -1)
    json = {
      "type" => "Point",
      "coordinates" => [10.0, 20.0, -1.0],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory_m).eql?(object))
  end

  def test_point_zm
    object = @geo_factory_zm.point(10, 20, -1, -2)
    json = {
      "type" => "Point",
      "coordinates" => [10.0, 20.0, -1.0, -2.0],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory_zm).eql?(object))
  end

  def test_line_string
    object = @geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])
    json = {
      "type" => "LineString",
      "coordinates" => [[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_polygon
    object = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24), @geo_factory.point(10, 20)]))
    json = {
      "type" => "Polygon",
      "coordinates" => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0], [10.0, 20.0]]],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_polygon_complex
    object = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])])
    json = {
      "type" => "Polygon",
      "coordinates" => [[[0.0, 0.0], [10.0, 0.0], [10.0, 10.0], [0.0, 10.0], [0.0, 0.0]], [[4.0, 4.0], [6.0, 5.0], [4.0, 6.0], [4.0, 4.0]]],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_multi_point
    object = @geo_factory.multi_point([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])
    json = {
      "type" => "MultiPoint",
      "coordinates" => [[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_multi_line_string
    object = @geo_factory.multi_line_string([@geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)]), @geo_factory.line_string([@geo_factory.point(1, 2), @geo_factory.point(3, 4)])])
    json = {
      "type" => "MultiLineString",
      "coordinates" => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0]], [[1.0, 2.0], [3.0, 4.0]]],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_multi_polygon
    object = @geo_factory.multi_polygon([@geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])]), @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(-10, -10), @geo_factory.point(-15, -10), @geo_factory.point(-10, -15), @geo_factory.point(-10, -10)]))])
    json = {
      "type" => "MultiPolygon",
      "coordinates" => [[[[0.0, 0.0], [10.0, 0.0], [10.0, 10.0], [0.0, 10.0], [0.0, 0.0]], [[4.0, 4.0], [6.0, 5.0], [4.0, 6.0], [4.0, 4.0]]], [[[-10.0, -10.0], [-15.0, -10.0], [-10.0, -15.0], [-10.0, -10.0]]]]
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_geometry_collection
    object = @geo_factory.collection([@geo_factory.point(10, 20), @geo_factory.collection([@geo_factory.point(12, 22), @geo_factory.point(-3, 24)])])
    json = {
      "type" => "GeometryCollection",
      "geometries" => [
        {
          "type" => "Point",
          "coordinates" => [10.0, 20.0],
        },
        {
          "type" => "GeometryCollection",
          "geometries" => [
            {
              "type" => "Point",
              "coordinates" => [12.0, 22.0],
            },
            {
              "type" => "Point",
              "coordinates" => [-3.0, 24.0],
            },
          ],
        },
      ],
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature
    object = @entity_factory.feature(@geo_factory.point(10, 20))
    json = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Point",
        "coordinates" => [10.0, 20.0],
      },
      "properties" => {},
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature_nulls
    feature = @entity_factory.feature(nil, nil, nil)
    json = RGeo::GeoJSON.encode(feature)
    obj = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    refute_nil(obj)
    assert_nil(obj.geometry)
    assert_equal({}, obj.properties)
  end

  def test_feature_complex
    object = @entity_factory.feature(@geo_factory.point(10, 20), 2, "prop1" => "foo", "prop2" => "bar")
    json = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Point",
        "coordinates" => [10.0, 20.0],
      },
      "id" => 2,
      "properties" => { "prop1" => "foo", "prop2" => "bar" },
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature_with_symbol_prop_keys
    object = @entity_factory.feature(@geo_factory.point(10, 20), 2, :prop1 => "foo", "prop2" => "bar")
    json = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Point",
        "coordinates" => [10.0, 20.0],
      },
      "id" => 2,
      "properties" => { "prop1" => "foo", "prop2" => "bar" },
    }
    assert_equal("foo", object.property("prop1"))
    assert_equal("bar", object.property(:prop2))
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature_collection
    geometries = [
      @geo_factory.point(10, 20),
      @geo_factory.point(11, 22),
      @geo_factory.point(10, 20)
    ]
    object = @entity_factory.feature_collection([
                                                  @entity_factory.feature(geometries[0]),
                                                  @entity_factory.feature(geometries[1]),
                                                  @entity_factory.feature(geometries[2], 8)
                                                ])
    json = {
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
            "type" => "Point",
            "coordinates" => [11.0, 22.0],
          },
          "properties" => {},
        },
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Point",
            "coordinates" => [10.0, 20.0],
          },
          "id" => 8,
          "properties" => {},
        },
      ]
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature_collection_empty
    object = @entity_factory.feature_collection([])
    json = {
      "type" => "FeatureCollection",
      "features" => []
    }
    assert_equal(json, RGeo::GeoJSON.encode(object))
    assert(RGeo::GeoJSON.decode(json, geo_factory: @geo_factory).eql?(object))
  end

  def test_feature_property
    feature = RGeo::GeoJSON::Feature.new(nil, nil, a: "b")
    assert_equal "b", feature.properties["a"]
    assert_equal "b", feature["a"]
  end

  def test_feature_cast
    factory = RGeo::Cartesian.factory(srid: 4326)
    poly = factory.polygon(factory.linear_ring([factory.point(0, 0), factory.point(10, 0), factory.point(10, 10), factory.point(0, 10), factory.point(0, 0)]))
    point_feature = RGeo::GeoJSON::Feature.new(factory.point(1, 1))
    assert poly.contains?(point_feature)
  end

  def test_feature_to_geojson
    json = {
      "type" => "Feature",
      "geometry" => {
        "type" => "Polygon",
        "coordinates" => [[[10.0, 20.0], [12.0, 22.0], [-3.0, 24.0], [10.0, 20.0]]]
      },
      "properties" => {}
    }
    feature = RGeo::GeoJSON.decode(json)
    assert_equal(
      json,
      feature.as_geojson
    )
    assert_equal(
      '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[10.0,20.0],[12.0,22.0],[-3.0,24.0],[10.0,20.0]]]},"properties":{}}',
      feature.to_geojson
    )
  end

  def test_feature_collection_to_geojson
    json = {
      "type" => "FeatureCollection",
      "features" => [
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Point",
            "coordinates" => [10.0, 20.0],
          },
          "properties" => {}
        }
      ]
    }
    feature_collection = RGeo::GeoJSON.decode(json)
    assert_equal(
      json,
      feature_collection.as_geojson
    )
    assert_equal(
      '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[10.0,20.0]},"properties":{}}]}',
      feature_collection.to_geojson
    )
  end
end
