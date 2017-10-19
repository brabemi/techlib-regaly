# app.rb
require 'json'
require 'sinatra'
require 'sinatra/activerecord'

require './models.rb'

get '/floor/?' do
  Floor.all.to_json
end

get '/floor/:id' do |id|
  Floor.find(id).to_json
end

get '/floor/:id/shelfrows/?' do |id|
  Floor.find(id).shelf_rows.to_json
end

get '/signature/?' do
  Signature.all.to_json
end

get '/signature/:id' do |id|
  Signature.find(id).to_json
end
