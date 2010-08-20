class CreateContactFormEmails < ActiveRecord::Migration
  def self.up
    create_table :contact_form_emails do |t|
      t.string :nickname
      t.text :content
      t.text :email
      t.string :company
    end
  end

  def self.down
    drop_table :contact_form_emails
  end
end
