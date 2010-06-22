require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  username { Faker::Internet.user_name }
  email { Faker::Internet.email }
end

User.blueprint do
  username
  password { 'password' }
  password_confirmation { 'password' }
  email
end
