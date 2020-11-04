# frozen_string_literal: true

module RGeo
  module GeoJSON
    # This object encapsulates encoding and decoding settings (principally
    # the RGeo::Feature::Factory and the RGeo::GeoJSON::EntityFactory to
    # be used) so that you can encode and decode without specifying those
    # settings every time.
    class Coder
      class Error < RGeo::GeoJSON::Error
      end

      # Create a new coder settings object. The geo factory is passed as
      # a required argument.
      #
      # Options include:
      #
      # [<tt>:geo_factory</tt>]
      #   Specifies the geo factory to use to create geometry objects.
      #   Defaults to the preferred cartesian factory.
      # [<tt>:entity_factory</tt>]
      #   Specifies an entity factory, which lets you override the types
      #   of GeoJSON entities that are created. It defaults to the default
      #   RGeo::GeoJSON::EntityFactory, which generates objects of type
      #   RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      #   See RGeo::GeoJSON::EntityFactory for more information.
      def initialize(opts = {})
        @geo_factory = opts.fetch(
          :geo_factory,
          RGeo::Cartesian.preferred_factory(uses_lenient_assertions: true)
        )
        @entity_factory = opts.fetch(:entity_factory, EntityFactory.instance)
        if @geo_factory.property(:has_m_coordinate)
          # If a GeoJSON has more than 2 elements, the first one should be
          # longitude and the second one latitude. M is not part of GeoJSON
          # specifications and only kept here for backward compatibilities.
          #
          # Quote from https://tools.ietf.org/html/rfc7946#section-3.1.1:
          #
          # > A position is an array of numbers.  There MUST be two or more
          # > elements.  The first two elements are longitude and latitude, or
          # > easting and northing, precisely in that order and using decimal
          # > numbers.  Altitude or elevation MAY be included as an optional third
          # > element.
          # >
          # > Implementations SHOULD NOT extend positions beyond three elements
          # > because the semantics of extra elements are unspecified and
          # > ambiguous.  Historically, some implementations have used a fourth
          # > element to carry a linear referencing measure (sometimes denoted as
          # > "M") or a numerical timestamp, but in most situations a parser will
          # > not be able to properly interpret these values.  The interpretation
          # > and meaning of additional elements is beyond the scope of this
          # > specification, and additional elements MAY be ignored by parsers.
          raise Error, "GeoJSON format cannot handle m coordinate."
        end

        @num_coordinates = 2
        @num_coordinates += 1 if @geo_factory.property(:has_z_coordinate)
      end

      # Encode the given object as GeoJSON. The object may be one of the
      # geometry objects specified in RGeo::Feature, or an appropriate
      # GeoJSON wrapper entity supported by this coder's entity factory.
      #
      # This method returns a JSON object (i.e. a hash). In order to
      # generate a string suitable for transmitting to a service, you
      # will need to JSON-encode it. This is usually accomplished by
      # calling <tt>to_json</tt> on the hash object, if you have the
      # appropriate JSON library installed.
      #
      # Returns nil if nil is passed in as the object.
      def encode(object)
        return nil if object.nil?

        if @entity_factory.is_feature_collection?(object)
          {
            "type" => "FeatureCollection",
            "features" => @entity_factory.map_feature_collection(object) { |f| encode_feature(f) },
          }
        elsif @entity_factory.is_feature?(object)
          encode_feature(object)
        else
          encode_geometry(object)
        end
      end

      # Decode an object from GeoJSON. The input may be a JSON hash, a
      # String, or an IO object from which to read the JSON string.
      # If an error occurs, nil is returned.

      def decode(input)
        if input.is_a?(IO)
          input = input.read rescue nil
        end
        if input.is_a?(String)
          input = MultiJson.load(input)
        end
        return unless input.is_a?(Hash)

        case input["type"]
        when "FeatureCollection"
          features = input["features"]
          features = [] unless features.is_a?(Array)
          decoded_features = []
          features.each do |f|
            if f["type"] == "Feature"
              decoded_features << decode_feature(f)
            end
          end
          @entity_factory.feature_collection(decoded_features)
        when "Feature"
          decode_feature(input)
        else
          decode_geometry(input)
        end
      end

      # Returns the RGeo::Feature::Factory used to generate geometry objects.

      attr_reader :geo_factory

      # Returns the RGeo::GeoJSON::EntityFactory used to generate GeoJSON
      # wrapper entities.

      attr_reader :entity_factory

      private

      def encode_feature(object)
        json = {
          "type" => "Feature",
          "geometry" => encode_geometry(@entity_factory.get_feature_geometry(object)),
          "properties" => @entity_factory.get_feature_properties(object).dup,
        }
        id = @entity_factory.get_feature_id(object)
        json["id"] = id if id
        json
      end

      def encode_geometry(object)
        return nil if object.nil?
        if object.factory.property(:has_m_coordinate)
          raise Error, "GeoJSON format cannot handle m coordinate."
        end

        case object
        when RGeo::Feature::Point,
             RGeo::Feature::LineString,
             RGeo::Feature::Polygon,
             RGeo::Feature::MultiPoint,
             RGeo::Feature::MultiLineString,
             RGeo::Feature::MultiPolygon
          {
            "type" => object.geometry_type.type_name,
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::GeometryCollection
          {
            "type" => "GeometryCollection",
            "geometries" => object.map { |geom| encode_geometry(geom) }
          }
        else
          nil
        end
      end

      def decode_feature(input)
        geometry = input["geometry"]
        if geometry
          geometry = decode_geometry(geometry)
          return unless geometry
        end
        @entity_factory.feature(geometry, input["id"], input["properties"])
      end

      def decode_geometry(input)
        case input["type"]
        when "GeometryCollection"
          decode_geometry_collection(input)
        when "Point"
          decode_point_coords(input["coordinates"])
        when "LineString"
          decode_line_string_coords(input["coordinates"])
        when "Polygon"
          decode_polygon_coords(input["coordinates"])
        when "MultiPoint"
          decode_multi_point_coords(input["coordinates"])
        when "MultiLineString"
          decode_multi_line_string_coords(input["coordinates"])
        when "MultiPolygon"
          decode_multi_polygon_coords(input["coordinates"])
        else
          raise Error, "'#{input['type']}' type is not part of GeoJSON spec."
        end
      end

      def decode_geometry_collection(input)
        geometries = input["geometries"]
        geometries = [] unless geometries.is_a?(Array)
        decoded_geometries = []
        geometries.each do |geometry|
          geometry = decode_geometry(geometry)
          decoded_geometries << geometry if geometry
        end
        @geo_factory.collection(decoded_geometries)
      end

      def decode_point_coords(point_coords)
        return unless point_coords.is_a?(Array)
        @geo_factory.point(*point_coords[0...@num_coordinates].map(&:to_f)) rescue nil
      end

      def decode_line_string_coords(line_coords)
        return unless line_coords.is_a?(Array)
        points = []
        line_coords.each do |point_coords|
          point = decode_point_coords(point_coords)
          points << point if point
        end
        @geo_factory.line_string(points)
      end

      def decode_polygon_coords(poly_coords)
        return unless poly_coords.is_a?(Array)
        rings = []
        poly_coords.each do |ring_coords|
          return unless ring_coords.is_a?(Array)
          points = []
          ring_coords.each do |point_coords|
            point = decode_point_coords(point_coords)
            points << point if point
          end
          ring = @geo_factory.linear_ring(points)
          rings << ring if ring
        end
        if rings.size == 0
          nil
        else
          @geo_factory.polygon(rings[0], rings[1..-1])
        end
      end

      def decode_multi_point_coords(multi_point_coords)
        return unless multi_point_coords.is_a?(Array)
        points = []
        multi_point_coords.each do |point_coords|
          point = decode_point_coords(point_coords)
          points << point if point
        end
        @geo_factory.multi_point(points)
      end

      def decode_multi_line_string_coords(multi_line_coords)
        return unless multi_line_coords.is_a?(Array)
        lines = []
        multi_line_coords.each do |line_coords|
          line = decode_line_string_coords(line_coords)
          lines << line if line
        end
        @geo_factory.multi_line_string(lines)
      end

      def decode_multi_polygon_coords(multi_polygon_coords)
        return unless multi_polygon_coords.is_a?(Array)
        polygons = []
        multi_polygon_coords.each do |poly_coords|
          poly = decode_polygon_coords(poly_coords)
          polygons << poly if poly
        end
        @geo_factory.multi_polygon(polygons)
      end
    end
  end
end
