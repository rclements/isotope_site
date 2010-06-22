class User < ActiveRecord::Base
  has_many :file_attachments
  acts_as_authentic
  acts_as_authorization_subject
  acts_as_authorization_object

  def to_s
    username
  end
end
