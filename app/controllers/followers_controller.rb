class FollowersController < ApplicationController
  after_action :audit_log, only: [ :create ]

  def create
    following = User.find(params[:user_id])
    follow = Follower.create(follower: current_user, following: following)
    if follow.save
      AuditLog.create(action: 0, target_controller: 'followers', user_id: current_user.id, target_id: follow.id, ip_address: request.remote_ip)
      redirect_to request.path, notice: t('follower.created', username: following.username)
    end
  end

  def destroy
    follow = Follower.find(params[:id])
    if follow.destroy
      AuditLog.find_by(target_controller: 'followers', target_id: follow.id).destroy
      redirect_to request.path, notice: t('follower.destroyed', username: follow.following.username)
    end
  end
end
