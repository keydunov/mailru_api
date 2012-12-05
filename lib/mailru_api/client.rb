require 'net/http'
require 'uri'
require 'digest/md5'
require 'json'
require 'active_support/inflector'

module MailruApi
	

	class Client
		MAILRU_API_URL = "http://www.appsmail.ru/platform/api?"
		MAILRU_METHODS = %w(audio stream users events friends payments photos messages guestbook notifications 
							widget mail)

		attr_accessor :app_id, :api_secret, :token 

		
		def initialize app_id, api_secret, session_key, prefix = nil
			@app_id, @api_secret, @token, @prefix = app_id, api_secret, session_key, prefix
		end


		# Call Mail.ru API
		def request method, params = {}
			method = method.to_s.camelize(:lower)
			params[:method] = @prefix ? "#{@prefix}.#{method}" : method
			params[:app_id] = @app_id
			params[:secure] = "1"
			params[:session_key] ||= @token
			params[:sig] = sig(params.tap do |s|
				# stringify keys
        		s.keys.each {|k| s[k.to_s] = s.delete k  }	
			end)
			response = JSON.parse(Net::HTTP.post_form(URI.parse(MAILRU_API_URL), params).body)      
       		# raise ServerError.new self, method, params, response['error'] if response['error']
    	 	response
		end	

		# Generate sig
		def sig(params)
			Digest::MD5::hexdigest(
      		params.keys.sort.map{|key| "#{key}=#{params[key]}"}.join + 
      		api_secret) 
		end	

		def self.create_method name
			define_method name do
				if (! var = instance_variable_get("@#{name}"))
            		instance_variable_set("@#{name}", var = ::MailruApi::Client.new(app_id, api_secret, token, name))
          		end
          		var
			end
		end

		for method in MAILRU_METHODS
			create_method method
		end


		# handle unknown methods
		def method_missing(name, *arg)
			request name, *arg
		end
	
		# Base error class
  	class Error < ::StandardError; end
  

	 # Server side error
	  class ServerError < Error
	    attr_accessor :session, :method, :params, :error
	    def initialize(session, method, params, error)
	      super "Server side error calling Mail.ru API method: #{error}"
	      @session, @method, @params, @error = session, method, params, error
	    end
	  end

	end
end