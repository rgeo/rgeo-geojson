# frozen_string_literal: true

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
      def coder(opts = {})
        Coder.new(opts)
      end
    end
  end
end
