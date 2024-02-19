class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?

  # before_action -> { sleep 3 } # added this to test custom _turbo_progress_bar.scss

  private

  def current_company
    @current_company ||= current_user.company if user_signed_in?
  end
  helper_method :current_company
end
