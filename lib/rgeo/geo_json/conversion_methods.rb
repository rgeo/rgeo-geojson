# frozen_string_literal: true

module RGeo
  # This module serves to provide handy methods when using GeoJSON. The methods
  # provided eases the passage between entities and GeoJSON String/Hash.
  module GeoJSON::ConversionMethods
    # Convert a geometry to a GeoJSON Hash
    def as_geojson
      GeoJSON.encode(self)
    end
    alias as_json as_geojson

    # Convert a geometry to a GeoJSON String
    def to_geojson
      ::MultiJson.dump(as_geojson)
    end
    alias to_json to_geojson
  end

  module Feature
    module Instance
      # Convert a geometry to a GeoJSON Hash
      def as_geojson
        GeoJSON.encode(self)
      end
      alias as_json as_geojson

      # Convert a geometry to a GeoJSON String
      def to_geojson
        ::MultiJson.dump(as_geojson)
      end
      alias as_json as_geojson
    end

    module Factory::Instance
      # Parses a GeoJSON String/Hash, or an IO object from which
      # the JSON string is read and returns the corresponding
      # feature. Returns nil if unable to parse.
      def parse_geojson(input)
        GeoJSON.decode(input, geo_factory: self)
      end
    end
  end
end
