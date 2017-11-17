require_relative 'geocoding'

class Address
  attr_reader :lat, :lng, :full_address

  class << self
    def from_coordinates(*coordinate_pairs)
      coordinate_pairs.map do |(latitude, longitude)|
        new(lat: latitude, lng: longitude)
          .reverse_geocode!
      end
    end
  end

  def initialize(lat: nil, lng: nil, full_address: nil)
    @lat = lat
    @lng = lng
    @full_address = full_address

    # NOTE: For the sake of this interview application
    # there doesn't seem to be any benefit to delaying the
    # geocoding. By calculating it up front, we avoid
    # an object with state

    # geocode! unless geocoded?
    # reverse_geocode! unless reverse_geocoded?
  end

  def geocoded?
    !(lat.nil? || lng.nil?)
  end

  def reverse_geocoded?
    !full_address.nil?
  end

  def geocode!
    result = Geocoder.search(full_address)&.first
    @lat = result&.latitude
    @lng = result&.longitude
    self
  end

  def reverse_geocode!
    @full_address = Geocoder.address [lat, lng]
    self
  end
end
