# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts "Parameters: #{params}" }                                               #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)

get "/" do
  @events = events_table.all
  puts @events.inspect
  view "events"
end

get "/events/:id" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    puts @event
    view "event"
end

get "/events/:id/rsvps/new" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    @rsvps = rsvps_table.where(:id => params["id"]).to_a[0]

    @count = rsvps_table.where(:id => params["id"], :going => true).count
    puts @event.inspect
    puts @rsvps.inspect
    view "new_rsvp"
end

get "/events/:id/rsvps/create" do
    params.inspect
    rsvps_table.insert(:event_id => params["id"],
                       :going => params["going"],
                        :name => params["name"],
                        :email => params["email"],
                        :comments => params["comments"])
    view "create_rsvp"
end