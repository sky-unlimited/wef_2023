class FollowersController < ApplicationController
  def create
    following = User.find(params[:user_id])
    if Follower.create(follower: current_user, following: following)
      redirect_to request.path, notice: t('follower.created', username: following.username)
    end
  end

  def destroy
    follow = Follower.find(params[:id])
    if follow.destroy
      redirect_to request.path, notice: t('follower.destroyed', username: follow.following.username)
    end
  end
end
