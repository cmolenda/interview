require 'sinatra/base'
Dir['./lib/*.rb'].each { |f| require f }

class Main < Sinatra::Base
  get '/' do
    coordinates = [
      [61.582195, -149.443512],
      [44.775211, -68.774184],
      [25.891297, -97.393349],
      [45.787839, -108.502110],
      [35.109937, -89.959983]
    ]

    addresses = Address.from_coordinates *coordinates
    erb :index,  locals: { addresses: addresses }
  end
end
