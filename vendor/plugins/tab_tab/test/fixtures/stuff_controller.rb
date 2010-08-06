class StuffController < ActionController::Base
  tab :stuff

  def show
    self
  end

  def edit
    tab :stuff => :edit
    self
  end
end