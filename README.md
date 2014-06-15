###Хелпер для генерации REST-like маршрутов для моделей Mongoid в Sinatra-приложениях

Хелпер добавляеn метод rest_for (<модель>), который генерирует GET /models/?, GET /model/:id/?, POST /models/?, PUT /model/:id/? работающие с данными в формате JSON.
    
    require 'sinatra'
    require 'sinatra/rest_helper'
    require 'mongoid'
    requrie 'mongoid-pagination' # если надо
    
    # добавляем описания моделей

    Dir[File.join(File.dirname(__FILE__), "app", "models", '*.rb')].each do |file|
      require file
    end
    
    class Hello < Sinatra::Base
    
      configure :development do
        set :filtered_fields, [:email] # опционально: возвращать только требуемые поля документов при get-запросах
        Mongoid.load!(File.expand_path(File.join("..", "config", "mongoid.yml")))
      end
    
      register Sinatra::RestHelper
    
      rest_for('User') # сгенерировать маршруты для класса User
    
    end

