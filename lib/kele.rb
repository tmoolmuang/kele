require "kele/error"
require "kele/roadmap"
require "httparty"
require 'json'

class Kele
  include HTTParty
  include Roadmap
  
  base_uri "https://www.bloc.io/api/v1"
  
  def initialize(email, password)
    response = self.class.post("/sessions", body: {"email": email, "password": password})
    raise KeleError.new(response.message) unless response.code == 200
    @auth_token = response["auth_token"]
  end
  
  def get_me
    response = self.class.get("/users/me", headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
  end
  
  def get_mentor_availability(mentor_id)
    response = self.class.get("/mentors/#{mentor_id}/student_availability", headers: { "authorization" => @auth_token })
    m = JSON.parse(response.body)
    arr = []
    m.each {|a| arr << a}
    return arr
  end
  
  private
  def get_mentor_id_for_user
    @user['current_enrollment']['mentor_id']
  end
  
end
