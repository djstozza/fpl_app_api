require "application_responder"

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  self.responder = ApplicationResponder
  respond_to :json

  private

  def record_not_found
    render status: 404
  end
end
