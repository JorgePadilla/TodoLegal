class ApplicationController < ActionController::Base

protected
  def after_sign_up_path_for(resource)
    items_path
  end
  def after_sign_in_path_for(resource)
    if Setting.maintenance
      return orders_path
    end
    items_path
  end
end
