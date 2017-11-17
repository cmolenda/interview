# NOTE: The original spec mixed the lat,lng and address for a Washington DC address
# and Washington PA address. I've consolidated them into one set of lat,lng and address
# for the entire spec.

RSpec.describe Address do
  let(:lat) { 38.8978707 }
  let(:lng) { -77.0370666 }
  let(:full_address) { '1600 Pennsylvania Avenue NW, Washington, DC 20500, USA' }
  let(:geo_resp_params) {
    # Keys MUST be strings
    [
      {
        'latitude'     => lat,
        'longitude'    => lng,
        'address'      => full_address,
        'state'        => 'District of Columbia',
        'state_code'   => 'DC',
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ]
  }

  subject(:address) { described_class.new lat: lat, lng: lng, full_address: full_address }

  around do |example|
    Geocoder::Lookup::Test.add_stub full_address, geo_resp_params
    Geocoder::Lookup::Test.add_stub [lat, lng], geo_resp_params

    example.run

    Geocoder::Lookup::Test.reset
  end

  describe 'geocoding' do
    subject(:address) { described_class.new lat: nil, lng: nil, full_address: full_address }

    before { address.geocode! }

    it 'fills latitude and longitude' do
      expect(address.lat).to eq(lat)
      expect(address.lng).to eq(lng)
    end

    it 'is considered geocoded' do
      expect(address).to be_geocoded
    end

  end

  describe '#geocoded?' do
    context 'when latitude is missing' do
      let(:lat) { nil }

      it { is_expected.not_to be_geocoded }
    end

    context 'when longitude is missing' do
      let(:lng) { nil }

      it { is_expected.not_to be_geocoded }
    end

    context 'when latitude and longitude are available' do
      it { is_expected.to be_geocoded }
    end

    context 'when already geocoded' do
      subject(:address) { described_class.new lat: 0, lng: 0 }

      it 'does not geocode' do
        expect(Geocoder).not_to receive(:search)
        address.geocode!
      end
    end
  end

  describe 'reverse geocoding' do
    subject(:address) { described_class.new lat: lat, lng: lng, full_address: nil }

    before { address.reverse_geocode! }

    it 'fills address' do
      expect(address.full_address).to eq(full_address)
    end

    it 'is considered reverse_geocoded' do
      expect(address).to be_reverse_geocoded
    end

    context 'when already reverse geocoded' do
      subject(:address) { described_class.new lat: nil, lng: nil, full_address: 'fake' }

      it 'does not reverse geocode' do
        expect(Geocoder).not_to receive(:search)
        address.reverse_geocode!
      end
    end
  end

  describe '#reverse_geocoded?' do
    context 'when full_address is missing' do
      let(:full_address) { nil }

      it { is_expected.not_to be_reverse_geocoded }
    end

    context 'when full_address is present' do
      it { is_expected.to be_reverse_geocoded }
    end
  end


  describe '::from_coordinates' do
    let(:lat_2) { 40.181306 }
    let(:lng_2) { -80.265949 }
    let(:coordinates) { [[lat, lng], [lat_2, lng_2]] }
    let(:full_address_2) { '31-99 N Pennsylvania Ave, Washington, PA 15301, USA' }

    let(:geo_resp_params_2) {
      [
        {
          'latitude'     => lat_2,
          'longitude'    => lng_2,
          'address'      => full_address_2,
          'state'        => 'Washington',
          'state_code'   => 'PA',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    }

    before do
      Geocoder::Lookup::Test.add_stub [lat_2, lng_2], geo_resp_params_2
    end

    it 'returns a reverse geolocated addresses for each coordinate' do
      expect(Address.from_coordinates(*coordinates).map(&:full_address))
        .to eq([full_address, full_address_2])
    end
  end

  describe '#coordinates' do
    it 'returns an array of latitude and longitude' do
      expect(address.coordinates).to eq([lat, lng])
    end
  end

  describe 'distance finding' do
    let(:detroit) { FactoryGirl.build :address, :as_detroit }
    let(:kansas_city) { FactoryGirl.build :address, :as_kansas_city }

    # This test feels brittle/describes implementation
    it 'calculates distance with the Geocoder API' do
      expect(Geocoder::Calculations).to receive(:distance_between).with detroit.coordinates, kansas_city.coordinates
      detroit.miles_to kansas_city
    end

    it 'returns the distance between two addresses' do
      expect(detroit.miles_to(kansas_city)).to be > 0
    end
  end
end
