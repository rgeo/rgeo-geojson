# frozen_string_literal: true

module RGeo
  module GeoJSON # :nodoc:
    module Tests # :nodoc:
      module Common # :nodoc:
        module ConversionTests # :nodoc:
          def test_geometry_to_geojson
            pt = @factory.point(1, 2)
            assert_equal(
              { "type" => "Point", "coordinates" => [1.0, 2.0] },
              pt.as_geojson
            )
            assert_equal(
              '{"type":"Point","coordinates":[1.0,2.0]}',
              pt.to_geojson
            )
          end

          def test_parse_geojson
            pt = @factory.point(1, 2)
            assert_equal(pt, @factory.parse_geojson(pt.as_geojson))
            assert_equal(pt, @factory.parse_geojson(pt.to_geojson))
          end
        end
      end
    end
  end
end
