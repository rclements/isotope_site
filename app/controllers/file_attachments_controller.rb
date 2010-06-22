class FileAttachmentsController < ApplicationController
  before_filter :redirect_if_no_user, :only => [:new, :create]
  before_filter :load_new_file_attachment, :only => [:new, :create]
  before_filter :load_file_attachment, :only => [:show]
  layout 'subpage'

  protected
  def redirect_if_no_user
    unless params[:user_id]
      redirect_to "/"
    end
  end

  def load_new_file_attachment
    @file_attachment = FileAttachment.new(params[:file_attachment])
    @file_attachment.user_id = params[:user_id]
  end

  def load_file_attachment
    @file_attachment = FileAttachment.find(params[:id])
  end

  public
  def show
    send_file(@file_attachment.attachment_file.path, :disposition => 'attachment')
  end

  def new
  end

  def create
    @user = User.find(params[:user_id])
    if @user && @user == current_user && @file_attachment.save
      flash[:notice] = "File Attachment created successfully."
      current_user.has_role!(:admin, @file_attachment)
      redirect_to user_path(@user)
    else
      flash.now[:error] = "There was a problem saving the file."
      render :action => :new
    end
  end
end
