class Users::RegistrationForm < ApplicationInteraction
  object :user, class: User, default: -> { User.new }

  model_fields :user do
    string :email
    string :username
    string :password
  end

  validates :email, :username, :password, presence: true

  validate :username_uniqueness
  validate :email_uniqueness

  run_in_transaction!

  def execute
    user.assign_attributes(model_fields(:user))
    user.save
    errors.merge!(user.errors)
    user
  end

  private

  def username_uniqueness
    return if username.blank?
    errors.add(:username, "#{username} has already been taken")
  end

  def email_uniqueness
    return if email.blank?
    errors.add(:email, "#{email} has already been taken")
  end
end
