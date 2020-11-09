# frozen_string_literal: true

require_relative "../test_helper"

class CoderTest < Minitest::Test # :nodoc:
  include TestHelper
  def setup
    @geo_factory = RGeo::Cartesian.simple_factory(srid: 4326)
    @entity_factory = RGeo::GeoJSON::EntityFactory.instance
    @coder = RGeo::GeoJSON::Coder.new(
      geo_factory: @geo_factory,
      entity_factory: @entity_factory
    )
  end

  def test_encode_geometry_point
    point = rand_point
    assert_equal(
      { "type" => "Point", "coordinates" => [point.x, point.y] },
      @coder.send(:encode_geometry, point)
    )
  end

  def test_encode_geometry_linestring
    point1 = rand_point
    point2 = rand_point
    point3 = rand_point
    line = @geo_factory.line_string([point1, point2, point3])
    assert_equal(
      { "type" => "LineString", "coordinates" => [
        [point1.x, point1.y], [point2.x, point2.y], [point3.x, point3.y]
      ] },
      @coder.send(:encode_geometry, line)
    )
  end

  def test_encode_geometry_polygon
    point1 = @geo_factory.point(1.0, 2.0)
    point2 = @geo_factory.point(3.4, 2.0)
    point3 = @geo_factory.point(1.0, 3.0)
    exterior = @geo_factory.linear_ring([point1, point2, point3, point1])
    polygon = @geo_factory.polygon(exterior)
    assert_equal(
      { "type" => "Polygon", "coordinates" => [[
        [point1.x, point1.y],
        [point2.x, point2.y],
        [point3.x, point3.y],
        [point1.x, point1.y]
      ]] },
      @coder.send(:encode_geometry, polygon)
    )
  end

  def test_encode_geometry_polygon_with_one_hole
    point1 = @geo_factory.point(6.1, 4.2)
    point2 = @geo_factory.point(5.1, 6.2)
    point4 = @geo_factory.point(10.1, 0.2)
    point3 = @geo_factory.point(4.1, 4.2)
    point5 = @geo_factory.point(10.1, 9.2)
    point6 = @geo_factory.point(0.1, 0.2)
    point7 = @geo_factory.point(0.1, 9.2)
    exterior = @geo_factory.linear_ring([point1, point2, point3, point4, point1])
    interior = @geo_factory.linear_ring([point5, point6, point7, point5])
    polygon = @geo_factory.polygon(exterior, [interior])
    assert_equal(
      { "type" => "Polygon", "coordinates" => [
        [
          [point1.x, point1.y],
          [point2.x, point2.y],
          [point3.x, point3.y],
          [point4.x, point4.y],
          [point1.x, point1.y]
        ],
        [
          [point5.x, point5.y],
          [point6.x, point6.y],
          [point7.x, point7.y],
          [point5.x, point5.y]
        ]
      ] },
      @coder.send(:encode_geometry, polygon)
    )
  end

  def test_encode_geometry_multipoint
    point1 = rand_point
    point2 = rand_point
    multipoint = @geo_factory.multi_point([point1, point2])
    assert_equal(
      { "type" => "MultiPoint", "coordinates" => [
        [point1.x, point1.y], [point2.x, point2.y]
      ] },
      @coder.send(:encode_geometry, multipoint)
    )
  end

  def test_encode_geometry_multilinestring
    linestring1 = rand_linestring(2)
    linestring2 = rand_linestring(3)
    multilinestring = @geo_factory.multi_line_string([linestring1, linestring2])
    assert_equal(
      { "type" => "MultiLineString", "coordinates" => [
        linestring1.coordinates,
        linestring2.coordinates
      ] },
      @coder.send(:encode_geometry, multilinestring)
    )
  end

  def test_encode_geometry_multipolygon
    point1 = @geo_factory.point(0, 0)
    point2 = @geo_factory.point(0, 10)
    point3 = @geo_factory.point(10, 10)
    point4 = @geo_factory.point(10, 0)
    point5 = @geo_factory.point(4, 4)
    point6 = @geo_factory.point(5, 6)
    point7 = @geo_factory.point(6, 4)
    point8 = @geo_factory.point(0, -10)
    point9 = @geo_factory.point(-10, 0)
    exterior1 = @geo_factory.linear_ring([point1, point9, point8, point1])
    exterior2 = @geo_factory.linear_ring([point1, point4, point3, point2, point1])
    interior2 = @geo_factory.linear_ring([point5, point6, point7, point5])
    exterior3 = @geo_factory.linear_ring([point1, point3, point2, point1])
    poly1 = @geo_factory.polygon(exterior1)
    poly2 = @geo_factory.polygon(exterior2, [interior2])
    poly3 = @geo_factory.polygon(exterior3)
    multypolygon = @geo_factory.multi_polygon([poly1, poly2, poly3])
    assert_equal(
      { "type" => "MultiPolygon", "coordinates" => [
        [ # poly1
          exterior1.coordinates
        ],
        [ # poly2
          exterior2.coordinates,
          interior2.coordinates
        ],
        [ # poly3
          exterior3.coordinates
        ]
      ] },
      @coder.send(:encode_geometry, multypolygon)
    )
  end

  def test_encode_geometry_geometrycollection
  end
end
