class FaqsController < ApplicationController
    skip_before_action :authenticate_user!
  def index
    @faqs = Faq.all.where(lang: I18n.locale).order(rank: :asc)
  end
end
