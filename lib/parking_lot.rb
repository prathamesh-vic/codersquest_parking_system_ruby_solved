require_relative './parking_floor'

class ParkingLot
  attr_reader :name, :address, :floors, :parked_vehicles
  def initialize(name, address, no_of_floors)
    @name = name
    @address = address
    @floors = []
    @parked_vehicles = {}
    for i in 0..no_of_floors - 1
      @floors[i] = ParkingFloor.new
    end
  end
end
