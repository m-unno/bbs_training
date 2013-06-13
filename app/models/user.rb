class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :account, :password_digest, :password, :password_confirmation
end
