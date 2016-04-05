require "minitest/autorun"
require "rgeo/geo_json"

class BasicTest < Minitest::Test # :nodoc:
  def setup
    @geo_factory = RGeo::Cartesian.simple_factory(srid: 4326)
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
    obj_ = RGeo::GeoJSON.decode(json, geo_factory: @geo_factory)
    refute_nil(obj_)
    assert_nil(obj_.geometry)
    assert_equal({}, obj_.properties)
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
    object = @entity_factory.feature_collection([@entity_factory.feature(@geo_factory.point(10, 20)), @entity_factory.feature(@geo_factory.point(11, 22)), @entity_factory.feature(@geo_factory.point(10, 20), 8)])
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

  def test_feature_property
    feature = RGeo::GeoJSON::Feature.new(nil, nil, a: "b")
    assert_equal "b", feature.properties["a"]
    assert_equal "b", feature["a"]
  end
end
