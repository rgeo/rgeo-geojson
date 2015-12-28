module RGeo
  module GeoJSON
    class << self
      # High-level convenience routine for encoding an object as GeoJSON.
      # Pass the object, which may one of the geometry objects specified
      # in RGeo::Feature, or an appropriate GeoJSON wrapper entity such
      # as RGeo::GeoJSON::Feature or RGeo::GeoJSON::FeatureCollection.
      #
      # The only option supported is <tt>:entity_factory</tt>, which lets
      # you override the types of GeoJSON entities supported. See
      # RGeo::GeoJSON::EntityFactory for more information. By default,
      # encode supports objects of type RGeo::GeoJSON::Feature and
      # RGeo::GeoJSON::FeatureCollection.

      def encode(object, opts = {})
        Coder.new(opts).encode(object)
      end

      # High-level convenience routine for decoding an object from GeoJSON.
      # The input may be a JSON hash, a String, or an IO object from which
      # to read the JSON string.
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
      #   library in Ruby 1.9, but requires the "json" gem in Ruby 1.8.
      #   If a parser is not specified, then the decode method will not
      #   accept a String or IO object; it will require a Hash.

      def decode(input_, opts = {})
        Coder.new(opts).decode(input_)
      end

      # Creates and returns a coder object of type RGeo::GeoJSON::Coder
      # that encapsulates encoding and decoding settings (principally the
      # RGeo::Feature::Factory and the RGeo::GeoJSON::EntityFactory to be
      # used).
      #
      # The geo factory is a required argument. Other options include:
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
      #   library in Ruby 1.9, but requires the "json" gem in Ruby 1.8.
      #   If a parser is not specified, then the decode method will not
      #   accept a String or IO object; it will require a Hash.

      def coder(opts = {})
        Coder.new(opts)
      end
    end
  end
end
