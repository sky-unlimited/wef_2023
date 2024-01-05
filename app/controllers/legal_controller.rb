class LegalController < ApplicationController
  skip_before_action :authenticate_user!

  def privacy
  end

  def terms_and_conditions
  end
end
