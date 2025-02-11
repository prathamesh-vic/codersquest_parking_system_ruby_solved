class ParkingFloor
  attr_reader :total_slots, :total_car_slots, :total_bike_slots, :total_truck_slots, :total_van_slots
  attr_accessor :available_car_slots, :available_bike_slots, :available_truck_slots, :available_van_slots
  def initialize()
    @total_slots = 0
    @total_car_slots = 0
    @available_car_slots = 0
    @total_bike_slots = 0
    @available_bike_slots = 0
    @total_truck_slots = 0
    @available_truck_slots = 0
    @total_van_slots = 0
    @available_van_slots = 0
  end

  def add_car_slots(slots)
    @total_car_slots += slots
    @available_car_slots += slots
    @total_slots += slots
  end

  def add_bike_slots(slots)
    @total_bike_slots += slots
    @available_bike_slots += slots
    @total_slots += slots
  end

  def add_truck_slots(slots)
    @total_truck_slots += slots
    @available_truck_slots += slots
    @total_slots += slots
  end

  def add_van_slots(slots)
    @total_van_slots += slots
    @available_van_slots += slots
    @total_slots += slots
  end
end
