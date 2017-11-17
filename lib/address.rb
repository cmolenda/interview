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
  end

  def geocoded?
    !(lat.nil? || lng.nil?)
  end

  def reverse_geocoded?
    !full_address.nil?
  end

  def geocode!
    unless geocoded?
      result = Geocoder.search(full_address)&.first
      @lat = result&.latitude
      @lng = result&.longitude
    end

    self
  end

  def reverse_geocode!
    @full_address = Geocoder.address [lat, lng] unless reverse_geocoded?
    self
  end

  def miles_to(destination_address)
    Geocoder::Calculations.distance_between coordinates, destination_address.coordinates
  end

  def coordinates
    [lat, lng]
  end
end
