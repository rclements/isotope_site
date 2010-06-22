class FileAttachment < ActiveRecord::Base
  belongs_to :user
  has_attached_file :attachment_file
  validates_attachment_presence :attachment_file
  acts_as_authorization_object
end
