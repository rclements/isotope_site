class UsersController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:create, :destroy, :edit, :update]
  layout 'subpage'

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Registration Successful!"
      redirect_to root_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
 
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to root_url
    else
      render :action => :edit
    end
  end

end
