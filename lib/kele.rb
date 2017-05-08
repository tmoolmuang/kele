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
  
  def get_messages(page_num=nil)
    unless page_num
      response = self.class.get("/message_threads", headers: { "authorization" => @auth_token })
    else
      response = self.class.get("/message_threads", body: { "page" => page_num }, headers: { "authorization" => @auth_token })
    end
    JSON.parse(response.body)
  end
  
  def create_message(sender, recipient_id, token=nil, subject, stripped_text)
    self.class.post("/messages", 
      body: { "sender" => sender, 
              "recipient_id" => recipient_id, 
              "token" => token,
              "subject" => subject, 
              "stripped-text" => stripped_text },
      headers: { "authorization" => @auth_token } )
  end
  
  def create_submission(checkpoint_id, assignment_branch, assignment_commit_link, comment)
    self.class.post("/checkpoint_submissions", 
      body: { "enrollment_id" => get_enrollment_id_for_user, 
              "checkpoint_id" => checkpoint_id, 
              "assignment_branch" => assignment_branch, 
              "assignment_commit_link" => assignment_commit_link, 
              "comment" => comment },
      headers: { "authorization" => @auth_token } )
  end
  
  private
  def get_mentor_id_for_user
    @user['current_enrollment']['mentor_id']
  end
  
  def get_enrollment_id_for_user
    @user['current_enrollment']['id']
  end

end
