class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :login]
  authorize_resource

  def index
    @users = User.search(params, admin_users_path)
    flash.now[:warning] = t("no_matches") if @users.count == 0
    save_last_search(:admin, :users)
  end

  def show
    @entries = @user.journal_entries if current_user.roles.present?
  end

  def update
    if @user.update(user_params)
      @user.journal(:update, current_user.name, request.ip)
      redirect_to [:admin, @user], notice: "User was successfully updated"
    else
      render action: "edit"
    end
  end

  def destroy
    email = @user.email
    if reason = @user.reason_to_not_delete
      redirect_to admin_user_path(@user), alert: "Can't delete #{email} because this user #{reason}"
    else
      @user.journal(:destroy, current_user.name, request.ip)
      @user.destroy
      redirect_to admin_users_path, notice: "User #{email} was successfully deleted"
    end
  end

  def login
    if !current_user.admin?
      redirect_to admin_user_path(@user), alert: "Only administrators can switch user"
    elsif @user.id == current_user.id
      redirect_to admin_user_path(@user), alert: "Can't switch to the current user"
    elsif @user.admin?
      redirect_to admin_user_path(@user), alert: "Can't switch to another administrator"
    else
      session[:user_id] = @user.id
      redirect_to home_path, notice: "#{t('session.signed_in_as')} #{@user.email}"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:password, :expiry, :status, :verify, roles: [])
  end
end
