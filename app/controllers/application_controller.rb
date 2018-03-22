require "application_responder"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  self.responder = ApplicationResponder
  respond_to :json
end
