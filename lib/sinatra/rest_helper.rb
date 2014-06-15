require 'sinatra/base'
require 'json'

module Sinatra
  module RestHelper
    def rest_for(model)
      noun = model.to_s
      plural = "/#{noun}s/?"
      element = "/#{noun}/:id/?"
      m = nil
      begin
        m = Object.const_get(noun.capitalize)
      rescue Exception => e
        return nil
      end
      filtered = settings.filtered_fields && settings.filtered_fields.size == 0 ? m : m.only(*settings.filtered_fields)

      get plural do
        content_type :json
        page = params['page'] || 0
        return {:error => "nothing found for #{model}"}.to_json unless m
        # filtered = return_fields.size == 0 ? m : m.only(*return_fields)
        if filtered.respond_to? :paginate
          filtered.paginate(:page => page, :per_page => 20).all.to_json
        else
          filtered.limit(20).all.to_json
        end
      end

      get element do
        content_type :json
        return {:error => "nothing found for #{model}"}.to_json unless m
        e = m.find(params[:id])
        return {:error => "no such record for id: #{params[:id]}"}.to_json unless e
        e.to_json
      end

      post plural do
        content_type :json
        return {:error => "nothing found for #{model}"}.to_json unless m
        begin
          data = JSON.parse(request.body.read)
          e = m.new( data )
          e.save
        rescue JSON::ParseError => err
          return {:error => "malformed json"}.to_json
        rescue
          "something went wrong"
        end
      end

      delete element do
        content_type :json
        return {:error => "nothing found for #{model}"}.to_json unless m
        e = m.find(params[:id])
        return {:error => "no such record for id: #{params[:id]}"}.to_json unless e
        e.delete
      end

      put element do
        content_type :json
        return {:error => "nothing found for #{model}"}.to_json unless m
        e = m.find(params[:id])
        return {:error => "no such record for id: #{params[:id]}"}.to_json unless e
        begin
          data = JSON.parse(request.body.read)
          data.each { |k,v|
            e.send("#{k}=",v) if m.fields.has_key? k
          }
          e.save
        rescue JSON::ParseError => err
          return {:error => "malformed json"}.to_json
        rescue Exception => exp
          "something went wrong"
        end
      end
    end
  end

  register RestHelper
end