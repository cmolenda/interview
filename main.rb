require 'sinatra/base'
Dir['./lib/*.rb'].each { |f| require f }

class Main < Sinatra::Base
  get '/' do

    display_address = Struct.new :full_address, :miles_to_the_whitehouse

    whitehouse =
      Address
        .new(full_address: '1600 Pennsylvania Avenue NW Washington, D.C. 20500')
        .geocode!

    coordinates = [
      [61.582195, -149.443512],
      [44.775211, -68.774184],
      [25.891297, -97.393349],
      [45.787839, -108.502110],
      [35.109937, -89.959983]
    ]

    display_addresses =
      Address
        .from_coordinates(*coordinates)
        .map { |address|
          miles = whitehouse.miles_to address
          display_address.new address.full_address, miles
        }
        .sort_by(&:miles_to_the_whitehouse)

    erb :index,  locals: { addresses: display_addresses }
  end
end
