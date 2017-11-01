# app.rb
require 'json'
require 'sinatra'
require 'sinatra/activerecord'

require './models.rb'

get '/floor/?' do
  Floor.all.to_json
end

get '/floor/:id/?' do |id|
  Floor.find(id).to_json
end

get '/floor/:id/shelfrows/?' do |id|
  Floor.find(id).shelf_rows.to_json
end

get '/signature/?' do
  query = []
  query_params = {}
  if params[:from_year]
    query_params[:year_max] = params[:from_year].to_i
    query.push('year_max >= :year_max')
  end
  if params[:to_year]
    query_params[:year_min] = params[:to_year].to_i
    query.push('year_min <= :year_min')
  end
  if params[:sig_num_min]
    query_params[:sig_num_min] = params[:sig_num_min].to_i
    query.push('signature_number >= :sig_num_min')
  end
  if params[:sig_num_max]
    query_params[:sig_num_max] = params[:sig_num_max].to_i
    query.push('signature_number <= :sig_num_max')
  end
  if params[:sig_pref]
    query_params[:sig_pref] = params[:sig_pref]
    # query_params[:sig_pref] = "%#{params[:sig_pref]}%"
    query.push('signature_prefix = :sig_pref')
  end
  # p query.join(' and '), query_params
  Signature.where(query.join(' and '), query_params).to_json
  # sql = Signature.where(query.join(' and '), query_params).to_sql
  # ActiveRecord::Base.connection.exec_query(sql).to_json
  # [].to_json
  # Signature.all.to_json
end

get '/signature/:id/?' do |id|
  Signature.find(id).to_json
end