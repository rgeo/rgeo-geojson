# frozen_string_literal: true

module RGeo
  # This module is here to fill the gap between what is a GeometryCollection (GIS)
  # and a FeatureCollection (GeoJSON).
  #
  # Note for contributors, you can rely on `@features` to be defined and
  # you can consider working with an Enumerable wrapping `@features`. See
  # GeoJSON::FeatureCollection.
  module GeoJSON::CollectionMethods
    # There is tight coupling between {FeatureCollection} and this, hence the
    # guard.
    private_class_method def self.included(base)
      return if base.to_s == "RGeo::GeoJSON::FeatureCollection"

      raise Error::RGeoError, "#{self.class} must only be used by FeatureCollection"
    end

    private def method_missing(symbol, *args)
      return super unless any? { |feature| feature.respond_to?(symbol) }

      raise Error::UnsupportedOperation, "Method FeatureCollection##{symbol} " \
        "is not defined. You may consider filing an issue or opening a pull " \
        "request at https://github.com/rgeo/rgeo-geojson"
    end

    def contains?(geometry)
      any? { |feature| feature.contains?(geometry) }
    end

    def intersects?(geometry)
      any? { |feature| feature.intersects?(geometry) }
    end
  end
end
