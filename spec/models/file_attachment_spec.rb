require 'spec_helper'

describe FileAttachment do
  describe "validations on create" do
    should_belong_to :user
    should_validate_presence_of :attachment_file
  end

end
