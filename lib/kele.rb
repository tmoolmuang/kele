require "kele/error"
require "httparty"

class Kele
  include HTTParty
  
  def initialize(email, password)
    response = self.class.post(bloc_api("sessions"), body: {"email": email, "password": password})
    raise KeleError.new(response.message) unless response.code == 200
    @auth_token = response["auth_token"]
  end
  
  private
  def bloc_api(endpoint)
    "https://www.bloc.io/api/v1/#{endpoint}"
  end
  
end
