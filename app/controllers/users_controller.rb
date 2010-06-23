class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:create, :destroy, :edit, :update]
  before_filter :require_same_user, :only => [:show]
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

  def index
    @users = User.find(:all)
  end
  
  def show
    @user = User.find(params[:id])
    @users = User.find(:all)
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

  private

  def require_same_user
    unless (current_user == User.find(params[:id])) || current_user.has_role?(:admin, @user)
      store_location
      flash[:notice] = "You do not have permission to access this page."
      redirect_to user_path(current_user)
      return false
    end

  end

end
