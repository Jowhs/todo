require 'sinatra'
require 'sinatra/reloader'
require 'sequel'
require 'yaml'
require 'haml'
require 'digest'
require 'pry'
require 'pry-byebug'
require 'slim'
require_relative 'lib/routes'

class Todo < Sinatra::Application
    set :environment, ENV['RACK_ENV']
    set :method_override, true
    
    configure :development do
        register Sinatra::Reloader
        env = ENV['RACK_ENV']
        DB = Sequel.connect(YAML.load(File.open('database.yml'))[env])
        #DB = Sequel.connect("mysql2://root:pass@mysql.getapp.docker/todo")
        Dir[File.join(File.dirname(__FILE__),'models','*.rb')].each { |model| require model } 
    end

    enable :sessions
    enable :reloader
end