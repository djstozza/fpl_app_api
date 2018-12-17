FactoryBot.define do
  factory :user, class: User do
    sequence :username do |n|
      "username #{n}"
    end
    sequence :email do |n|
      "user#{n}@gmail.com"
    end
    password { 'abcd1234' }
  end
end
