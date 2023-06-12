class PilotPrefsController < ApplicationController
  def edit
    @pilot_pref = current_user.pilot_pref
  end
  def update
    @pilot_pref = PilotPref.find(params[:id])
    if @pilot_pref.update(pilot_pref_params)
      redirect_to pilot_prefs_edit_path
    else
      render "edit", pilot_pref: @pilot_pref
    end
  end

  private

  def pilot_pref_params
    params.require(:pilot_pref).permit(:user_id, :weather_profile, :min_runway_length, :max_gnd_wind_speed, :min_runway_length)
  end
end
