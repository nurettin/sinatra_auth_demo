# I had do use Bundler.require because piece of crap sinatra-authentication gem had a Sequel error in it and I'm using my fork from github.
# But piece of crap sinatra-authentication gem requires you to have a DB constant, 
# so I made a lazy-loading DB that will let Bundler.require load the excellent Sequel gem.

class LazyDB
  attr_accessor :self
  def method_missing(m, *args, &block)
    if !@self
      @self= Sequel.connect("sqlite://db/db.sqlite3")
      @self.loggers<< Logger.new(STDOUT)
    end
    @self.send(m, *args, &block)
  end
end
DB= LazyDB.new

require "logger"
require "tilt/erb"
require "rack-flash"
require "bundler"
Bundler.require

# Further configuration to accommodate piece of crap sinatra-authentication
configure do
  use Rack::Session::Cookie, secret: "Some Secret"
  use Rack::Flash
  set template_engine: :erb
  # Yeah I had to convert all the haml views into erb because I want to use erb layout. Thanks, sinatra-authentication
  set :sinatra_authentication_view_path, "views"
end

enable :logging  

Sequel.extension :migration
Sequel::Model.plugin :timestamps

require "./main"

run Sinatra::Application

