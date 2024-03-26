class FollowersController < ApplicationController
  def create
    following = User.find(params[:user_id])
    follow = Follower.create(follower: current_user, following: following)
    if follow.save
      redirect_back fallback_location: pilot_path(following), notice: t('follower.created', username: following.username)
    end
  end

  def destroy
    follow = Follower.find(params[:id])
    if follow.destroy
      redirect_back fallback_location: pilot_path(follow.following), notice: t('follower.destroyed', username: follow.following.username)
    end
  end
end
