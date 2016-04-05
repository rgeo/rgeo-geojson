module RGeo
  module GeoJSON
    # This object encapsulates encoding and decoding settings (principally
    # the RGeo::Feature::Factory and the RGeo::GeoJSON::EntityFactory to
    # be used) so that you can encode and decode without specifying those
    # settings every time.

    class Coder
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
      # [<tt>:json_parser</tt>]
      #   Specifies a JSON parser to use when decoding a String or IO
      #   object. The value may be a Proc object taking the string as the
      #   sole argument and returning the JSON hash, or it may be one of
      #   the special values <tt>:json</tt>, <tt>:yajl</tt>, or
      #   <tt>:active_support</tt>. Setting one of those special values
      #   will require the corresponding library to be available. Note
      #   that the <tt>:json</tt> library is present in the standard
      #   library in Ruby 1.9.
      #   If a parser is not specified, then the decode method will not
      #   accept a String or IO object; it will require a Hash.

      def initialize(opts = {})
        @geo_factory = opts[:geo_factory] || RGeo::Cartesian.preferred_factory
        @entity_factory = opts[:entity_factory] || EntityFactory.instance
        @json_parser = opts[:json_parser]
        case @json_parser
        when :json
          require "json" unless defined?(JSON)
          @json_parser = proc { |str| JSON.parse(str) }
        when :yajl
          require "yajl" unless defined?(Yajl)
          @json_parser = proc { |str| Yajl::Parser.new.parse(str) }
        when :active_support
          require "active_support/json" unless defined?(ActiveSupport::JSON)
          @json_parser = proc { |str| ActiveSupport::JSON.decode(str) }
        when Proc, nil
          # Leave as is
        else
          raise ::ArgumentError, "Unrecognzied json_parser: #{@json_parser.inspect}"
        end
        @num_coordinates = 2
        @num_coordinates += 1 if @geo_factory.property(:has_z_coordinate)
        @num_coordinates += 1 if @geo_factory.property(:has_m_coordinate)
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
        if @entity_factory.is_feature_collection?(object)
          {
            "type" => "FeatureCollection",
            "features" => @entity_factory.map_feature_collection(object) { |f| _encode_feature(f) },
          }
        elsif @entity_factory.is_feature?(object)
          _encode_feature(object)
        elsif object.nil?
          nil
        else
          _encode_geometry(object)
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
          input = @json_parser.call(input) rescue nil
        end
        unless input.is_a?(Hash)
          return nil
        end
        case input["type"]
        when "FeatureCollection"
          features = input["features"]
          features = [] unless features.is_a?(Array)
          decoded_features = []
          features.each do |f|
            if f["type"] == "Feature"
              decoded_features << _decode_feature(f)
            end
          end
          @entity_factory.feature_collection(decoded_features)
        when "Feature"
          _decode_feature(input)
        else
          _decode_geometry(input)
        end
      end

      # Returns the RGeo::Feature::Factory used to generate geometry objects.

      attr_reader :geo_factory

      # Returns the RGeo::GeoJSON::EntityFactory used to generate GeoJSON
      # wrapper entities.

      attr_reader :entity_factory

      def _encode_feature(object) # :nodoc:
        json = {
          "type" => "Feature",
          "geometry" => _encode_geometry(@entity_factory.get_feature_geometry(object)),
          "properties" => @entity_factory.get_feature_properties(object).dup,
        }
        id = @entity_factory.get_feature_id(object)
        json["id"] = id if id
        json
      end

      def _encode_geometry(object) # :nodoc:
        case object
        when RGeo::Feature::Point
          {
            "type" => "Point",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::LineString
          {
            "type" => "LineString",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::Polygon
          {
            "type" => "Polygon",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::MultiPoint
          {
            "type" => "MultiPoint",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::MultiLineString
          {
            "type" => "MultiLineString",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::MultiPolygon
          {
            "type" => "MultiPolygon",
            "coordinates" => object.coordinates
          }
        when RGeo::Feature::GeometryCollection
          {
            "type" => "GeometryCollection",
            "geometries" => object.map { |geom| _encode_geometry(geom) }
          }
        else
          nil
        end
      end

      def _decode_feature(input) # :nodoc:
        geometry = input["geometry"]
        if geometry
          geometry = _decode_geometry(geometry)
          return nil unless geometry
        end
        @entity_factory.feature(geometry, input["id"], input["properties"])
      end

      def _decode_geometry(input) # :nodoc:
        case input["type"]
        when "GeometryCollection"
          _decode_geometry_collection(input)
        when "Point"
          _decode_point_coords(input["coordinates"])
        when "LineString"
          _decode_line_string_coords(input["coordinates"])
        when "Polygon"
          _decode_polygon_coords(input["coordinates"])
        when "MultiPoint"
          _decode_multi_point_coords(input["coordinates"])
        when "MultiLineString"
          _decode_multi_line_string_coords(input["coordinates"])
        when "MultiPolygon"
          _decode_multi_polygon_coords(input["coordinates"])
        else
          nil
        end
      end

      def _decode_geometry_collection(input)  # :nodoc:
        geometries_ = input["geometries"]
        geometries_ = [] unless geometries_.is_a?(Array)
        decoded_geometries_ = []
        geometries_.each do |g_|
          g_ = _decode_geometry(g_)
          decoded_geometries_ << g_ if g_
        end
        @geo_factory.collection(decoded_geometries_)
      end

      def _decode_point_coords(point_coords)  # :nodoc:
        return nil unless point_coords.is_a?(Array)
        @geo_factory.point(*(point_coords[0...@num_coordinates].map(&:to_f))) rescue nil
      end

      def _decode_line_string_coords(line_coords) # :nodoc:
        return nil unless line_coords.is_a?(Array)
        points = []
        line_coords.each do |point_coords|
          point = _decode_point_coords(point_coords)
          points << point if point
        end
        @geo_factory.line_string(points)
      end

      def _decode_polygon_coords(poly_coords) # :nodoc:
        return nil unless poly_coords.is_a?(Array)
        rings = []
        poly_coords.each do |ring_coords|
          return nil unless ring_coords.is_a?(Array)
          points = []
          ring_coords.each do |point_coords|
            point = _decode_point_coords(point_coords)
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

      def _decode_multi_point_coords(multi_point_coords) # :nodoc:
        return nil unless multi_point_coords.is_a?(Array)
        points = []
        multi_point_coords.each do |point_coords|
          point = _decode_point_coords(point_coords)
          points << point if point
        end
        @geo_factory.multi_point(points)
      end

      def _decode_multi_line_string_coords(multi_line_coords) # :nodoc:
        return nil unless multi_line_coords.is_a?(Array)
        lines = []
        multi_line_coords.each do |line_coords|
          line = _decode_line_string_coords(line_coords)
          lines << line if line
        end
        @geo_factory.multi_line_string(lines)
      end

      def _decode_multi_polygon_coords(multi_polygon_coords) # :nodoc:
        return nil unless multi_polygon_coords.is_a?(Array)
        polygons = []
        multi_polygon_coords.each do |poly_coords|
          poly = _decode_polygon_coords(poly_coords)
          polygons << poly if poly
        end
        @geo_factory.multi_polygon(polygons)
      end
    end
  end
end
