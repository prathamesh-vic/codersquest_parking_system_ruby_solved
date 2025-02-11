# Parking System Design Challenge in ruby

Assumption is that you have ruby already installed. 

## Spinning up the server

Here we have used sinatra gem for creating a light weight web application. Refer https://github.com/sinatra/sinatra for installation.

Run `gem install sinatra rackup puma` and then for running the server run

`ruby app.rb`

To test if setup is working fine run


`curl http://localhost:4567/test_setup`

You should get `{"status":"success"}` response.

Please note that you would have to restart to let changes take effect. You can use code reloader if you want to avoid restarting your server.# codersquest_parking_system_ruby_solved
