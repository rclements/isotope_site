class CreateFileAttachments < ActiveRecord::Migration
  def self.up
    create_table :file_attachments do |t|
      t.integer :user_id
      t.string :attachment_file_file_file_name
      t.string :attachment_file_file_content_type
      t.integer :attachment_file_file_size
      t.datetime :attachment_file_file_updated_at
    end
  end

  def self.down
    drop_table :file_attachments
  end
end

