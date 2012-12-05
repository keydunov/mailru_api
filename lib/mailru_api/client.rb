require 'net/http'
require 'uri'
require 'digest/md5'
require 'json'
require 'active_support/inflector'

# Author:: Keydunov Artem
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

# Mail.ru REST API Документация - http://api.mail.ru/docs/reference/rest/

# Пример использования:
#   client = ::MailruApi::Client.new app_id, api_secret, access_token
#   client.stream.get_by_author 

module MailruApi
	class Client
		MAILRU_API_URL = "http://www.appsmail.ru/platform/api?"
		MAILRUAPI_METHODS = %w(audio stream users events friends payments photos messages guestbook notifications 
								widget mail)
		
		attr_accessor :client_id, :client_secret, :access_token 

		# ------ Конструктор, аргументы:
    # * client_id — идентификатор вашего сайта
    # * client_secret — секретный ключ вашего сайта, выданный при регистрации
    # * access_token — это идентификатор сессии, необходимый для работы с REST API.
    # ------ Подробнее см. http://api.mail.ru/docs/guides/oauth/sites/
		def initialize client_id, client_secret, access_token, prefix = nil
				@client_id, @client_secret, @access_token, @prefix = client_id, client_secret, access_token, prefix
		end  

		def request method, params = {}
			params[:method] = @prefix ? "#{@prefix}.#{method}" : method
			params[:app_id] = @client_id
			params[:secure] = "1"
			params[:session_key] ||= @access_token
			params[:sig] = sig(params.tap do |s|
				# stringify keys
        s.keys.each {|k| s[k.to_s] = s.delete k  }	
			end )
			puts params
			response = JSON.parse(Net::HTTP.post_form(URI.parse(MAILRU_API_URL), params).body)      
      if !response.is_a?(Array) and response['error']
      	raise ServerError.new self, method, params, response['error']['error_msg'] 
      end
    	response
		end	

		# ------ Создаем подпись запроса (http://api.mail.ru/docs/guides/restapi/#sig)
		def sig(params)
			Digest::MD5::hexdigest(
      		params.keys.sort.map{|key| "#{key}=#{params[key]}"}.join + 
      		client_secret) 
		end	

		# ------ Перехват неизвестных методов
		def method_missing(name, *arg)
				#Позволяет использовать названия методов в стиле Ruby (get_by_author вместо getByAuthor)
				method = name.to_s.camelize(:lower)
				request method, *arg
		end 

		# ------ Создаем методы (audio, stream и т.д.)  
		MAILRUAPI_METHODS.each do |name|
			self.send :define_method, name do 
				instance_variable_set("@#{name}", ::MailruApi::Client.new(@client_id, @client_secret, @access_token, name))
			end
		end


		# ------ Errors
		# Base error class
  	class Error < ::StandardError; end
  
	 	# Server side error
	  class ServerError < Error
	    attr_accessor :session, :method, :params, :error
	    def initialize(client, method, params, error)
	      super "Server side error calling Mail.ru API method: #{error}"
	      @client, @method, @params, @error = client, method, params, error
	    end
	  end


	end
end