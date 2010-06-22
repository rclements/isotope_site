class ChangeFileAttachmentFilename < ActiveRecord::Migration
  def self.up
    remove_column :file_attachments, :attachment_file_file_file_name
    add_column :file_attachments, :attachment_file_file_name, :string
  end

  def self.down
    add_column :file_attachments, :attachment_file_file_file_name, :string
    remove_column :file_attachments, :attachment_file_file_name
  end
end
