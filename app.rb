require 'sinatra'
require_relative './lib/parking_system'
require 'debug'

# https://github.com/sinatra/sinatra?tab=readme-ov-file#available-settings
# for preventing "attack prevented by Rack::Protection::HostAuthorization" error
# add your ngrok host to permitted_hosts below
set :host_authorization, :permitted_hosts => [".localhost", "9975530fb821.ngrok.app", "9a0b9998f66d.ngrok.app"]

# Code below is for testing the setup of the server, do not modify or else the first test
# might fail.
get '/test_setup' do
  content_type :json
  { status: "success" }.to_json
end

# curl --location --request POST 'localhost:4567/example_post_endpoint/12?foo=bar'
# below is an example of how to define a POST endpoint with path and query params
post '/example_post_endpoint/:id' do
  # query params can be read like this
  foo = @params['foo']
  # path params can be read like this
  id = @params['id']
  # request body params can be read like this
  req_body = JSON.parse(request.body.read) rescue nil

  content_type :json
  { status: "success", "id": id, "foo": foo, "req_body": req_body }.to_json
end

# Additional detail on how to use sinatara can be found here: https://github.com/sinatra/sinatra

# define routes below as needed for submitting test.

parking_system = ParkingSystem.new

post '/parking_lot' do
  @parking_lots ||= {}
  req_body = JSON.parse(request.body.read) rescue nil
  
  return invalid_input_error if req_body.nil?
  return invalid_input_error if req_body['name'].nil? || req_body['no_of_floors'].nil? || req_body['no_of_floors'] < 0
  parking_lot = parking_system.add_parking_lot(req_body['name'], req_body['address'], req_body['no_of_floors'])
  puts 
  content_type :json
  { status: "success",  "name": parking_lot.name}.to_json
end

post '/add_vehicle_slots' do
  req_body = JSON.parse(request.body.read) rescue nil
  return invalid_input_error(error: "No request body found") if req_body.nil?
  return invalid_input_error(error: "parking lot doesn't exist") if !parking_system.parking_lot_exists?(req_body['parking_lot_name'])
  return invalid_input_error(error: "floor or slots is invalid") if req_body['floor'].nil? || req_body['floor'] < 0 || req_body['slots'].nil?
  
  result = parking_system.add_vehicle_slots(req_body['parking_lot_name'], req_body['floor'], req_body['slots'])
  if result[:status] == "failed"
    return invalid_input_error(error: result[:error])
  end
  content_type :json
  { status: "success", floor: req_body['floor'], parking_lot_name: req_body['parking_lot_name'] }.to_json
end

get '/capacity' do
  parking_lot_name = @params['parking_lot_name']
  return invalid_input_error(error: "parking lot doesn't exist") if parking_lot_name.nil? || !parking_system.parking_lot_exists?(parking_lot_name)

  content_type :json
  parking_system.display_capacity(parking_lot_name)
end

delete '/parking_lot' do
  parking_system = ParkingSystem.new
  content_type :json
  { status: "success" }.to_json
end

post '/park' do
  req_body = JSON.parse(request.body.read) rescue nil
  parking_lot_name = req_body['parking_lot_name']
  return invalid_input_error(error: "parking lot doesn't exist") if parking_lot_name.nil? || !parking_system.parking_lot_exists?(parking_lot_name)
  parking_lot = parking_system.get_parking_lot(parking_lot_name)
  vehicle_registration_number = req_body['vehicle_registration_number']
  return invalid_input_error(error: "vehicle_registration_number is invalid") if vehicle_registration_number.nil?
  vehicle_type = req_body['vehicle_type']
  return invalid_input_error(error: "vehicle_type is invalid") if vehicle_type.nil? || !ParkingSystem::VALID_VEHICLE_TYPES.include?(vehicle_type)
  user_name = req_body['user_name']
  return invalid_input_error(error: "user_name is invalid") if user_name.nil?
  request_date_time = Time.parse(req_body['request_date_time']) rescue nil
  return invalid_input_error(error: "request_date_time is invalid") if request_date_time.nil?

  result = parking_system.park_vehicle(parking_lot_name, vehicle_registration_number, vehicle_type, user_name, request_date_time)
  if result[:status] == "failed"
    return invalid_input_error(error: result[:error])
  else
    content_type :json
    { status: "success", parking_time: req_body['request_date_time'], parking_lot_name: parking_lot_name, vehicle_registration_number: vehicle_registration_number, parking_lot_address: parking_lot.address, parking_lot_floor: result[:floor], user_name: user_name }.to_json
  end
end

post '/unpark' do
  req_body = JSON.parse(request.body.read) rescue nil
  parking_lot_name = req_body['parking_lot_name']
  return invalid_input_error(error: "parking lot doesn't exist") if parking_lot_name.nil? || !parking_system.parking_lot_exists?(parking_lot_name)
  vehicle_registration_number = req_body['vehicle_registration_number']
  return invalid_input_error(error: "vehicle_registration_number is invalid") if vehicle_registration_number.nil?
  request_date_time = Time.parse(req_body['request_date_time']) rescue nil
  return invalid_input_error(error: "request_date_time is invalid") if request_date_time.nil?

  result = parking_system.unpark_vehicle(parking_lot_name, vehicle_registration_number, request_date_time)
  if result[:status] == "failed"
    return invalid_input_error(error: result[:error])
  else
    content_type :json
    { status: "success", total_parking_hours: result[:total_parking_hours].to_s, fees: "#{result[:fees]}", user_name: result[:user_name], vehicle_registration_number: vehicle_registration_number }.to_json
  end
end

private

def invalid_input_error(error: nil)
  content_type :json
  { status: "failed", message: "Invalid input", error: error }.to_json
end