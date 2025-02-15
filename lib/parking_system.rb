require_relative './parking_lot'

class ParkingSystem
  VALID_VEHICLE_TYPES = ["car", "bike", "truck", "van"]
  def initialize
    @parking_lots = {}
  end

  def get_parking_lot(parking_lot_name)
    @parking_lots[parking_lot_name]
  end

  def add_parking_lot(name, address, no_of_floors)
    parking_lot = ParkingLot.new(name, address, no_of_floors)
    @parking_lots[parking_lot.name] = parking_lot
    parking_lot
  end

  def parking_lot_exists?(name)
    @parking_lots[name].nil? ? false : true
  end

  def add_vehicle_slots(parking_lot_name, floor, slots)
    parking_lot = @parking_lots[parking_lot_name]
    return {status: "failed", error: "Parking lot #{parking_lot_name} not found"} if parking_lot.nil?
    floor = parking_lot.floors[floor]
    return {status: "failed", error: "Floor #{floor} not found"} if floor.nil?
    return {status: "failed", error: "Invalid slot passed"} if invalid_input_vehicle_types_and_slots?(slots)

    slots.each do |slot|
      case slot["vehicle_type"]
      when "car"
        floor.add_car_slots(slot["available_slots"])
      when "bike"
        floor.add_bike_slots(slot["available_slots"])
      when "truck"
        floor.add_truck_slots(slot["available_slots"])
      when "van"
        floor.add_van_slots(slot["available_slots"])
      end
    end
    {status: "success"}
  end

  def display_capacity(parking_lot_name)
    parking_lot = @parking_lots[parking_lot_name]
    floors_res = {}
    parking_lot.floors.each_with_index do |floor, index|
      floors_res[index.to_s] = {
        "car" => {
          "total_slots" => floor.total_car_slots,
          "available_slots" => floor.available_car_slots,
        },
        "bike" => {
          "total_slots" => floor.total_bike_slots,
          "available_slots" => floor.available_bike_slots,
        },
        "truck" => {
          "total_slots" => floor.total_truck_slots,
          "available_slots" => floor.available_truck_slots,
        },
        "van" => {
          "total_slots" => floor.total_van_slots,
          "available_slots" => floor.available_van_slots,
        }
      }
    end
    {
      status: "success",
      floors: floors_res
    }.to_json
  end

  def park_vehicle(parking_lot_name, vehicle_registration_number, vehicle_type, user_name, request_date_time)
    parking_lot = @parking_lots[parking_lot_name]
    return {status: "failed", error: "Parking lot #{parking_lot_name} not found"} if parking_lot.nil?
    
    return {status: "failed", error: "Invalid vehicle type passed, #{vehicle_type}" } if !VALID_VEHICLE_TYPES.include?(vehicle_type)
    if parking_lot.parked_vehicles.has_key?(vehicle_registration_number)
      return {status: "failed", error: "Vehicle with registration number #{vehicle_registration_number} already parked"}
    end
    
    parking_lot.floors.each_with_index do |floor, index|
      if floor.send("available_#{vehicle_type}_slots") > 0
        case vehicle_type
        when "car"
          floor.available_car_slots -= 1
        when "bike"
          floor.available_bike_slots -= 1
        when "truck"
          floor.available_truck_slots -= 1
        when "van"
          floor.available_van_slots -= 1
        end
        parking_lot.parked_vehicles[vehicle_registration_number] = {user_name: user_name, request_date_time: request_date_time, vehicle_type: vehicle_type, floor_index: index}
        return {status: "success", message: "Vehicle parked successfully", floor: index}
      end
    end
    {status: "failed", error: "No slots available for vehicle type #{vehicle_type}"}
  end

  def unpark_vehicle(parking_lot_name, vehicle_registration_number, request_date_time)
    parking_lot = @parking_lots[parking_lot_name]
    return {status: "failed", error: "Parking lot #{parking_lot_name} not found"} if parking_lot.nil?
    
    if !parking_lot.parked_vehicles.has_key?(vehicle_registration_number)
      return {status: "failed", error: "Vehicle with registration number #{vehicle_registration_number} not found"}
    end

    parked_vehicle = parking_lot.parked_vehicles[vehicle_registration_number]
    total_hours = ((request_date_time - parked_vehicle[:request_date_time]) / 3600).ceil
    parking_fees = 0
    if total_hours <= 0
      return {status: "failed", error: "Invalid request date time as parking_time is greater than or equal to unparking_time"}
    elsif total_hours <= 1
      parking_fees = 100
    elsif total_hours == 2
      parking_fees = 140
    elsif total_hours == 3
      parking_fees = 180
    elsif total_hours > 3
      parking_fees = 180 + (total_hours - 3) * 30
    end

    parked_floor = parking_lot.floors[parked_vehicle[:floor_index]]
    case parked_vehicle[:vehicle_type]
    when "car"
      parked_floor.available_car_slots += 1
    when "bike"
      parked_floor.available_bike_slots += 1
    when "truck"
      parked_floor.available_truck_slots += 1
    when "van"
      parked_floor.available_van_slots += 1
    end
    parking_lot.parked_vehicles.delete(vehicle_registration_number)
    { status: "success", total_parking_hours: total_hours, fees: "#{parking_fees}Rs", user_name: parked_vehicle[:user_name], vehicle_registration_number: vehicle_registration_number }
  end

  private

  def invalid_input_vehicle_types_and_slots?(slots)
    return true if slots.nil?
    slots.each do |slot|
      if !VALID_VEHICLE_TYPES.include?(slot["vehicle_type"]) || slot["available_slots"] < 0
        return true
      end
    end
    false
  end
end
