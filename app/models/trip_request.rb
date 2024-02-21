# This manages the pilot's request to find defined amenities on / nearby the
#   airport.
#   Should we add new amenities, please update config/poi_catalogue.yml
class TripRequest < ApplicationRecord
  belongs_to :user
  belongs_to :airport

  # enum trip_mode: [ :custom, :events, :suggested ]
  enum :trip_mode, { I18n.t('activerecord.attributes.trip_request
                            .trip_mode_options.custom') => 0,
                     I18n.t('activerecord.attributes.trip_request
                            .trip_mode_options.events') => 1,
                     I18n.t('activerecord.attributes.trip_request
                            .trip_mode_options.suggested') => 2 }

  validates :trip_mode, inclusion: { in: trip_modes.keys }
  validates :end_date, comparison: {
                         greater_than_or_equal_to: :start_date,
                         message: I18n.t('trip_request.messages.
                                         end_date_greater_start_date')
                       },
                       unless: :end_date_not_null?
  validate :start_date_cannot_be_in_the_past
  validate :end_date_no_longer_than_7_days
  validate :check_at_least_one_airport_type
  validate :check_at_least_one_poi_selected

  private

  def end_date_not_null?
    end_date.nil?
  end

  def start_date_cannot_be_in_the_past
    return unless start_date.present? && start_date.to_date < Date.today

    errors.add(:start_date, "can't be in the past")
  end

  def end_date_no_longer_than_7_days
    return unless end_date.to_date - Date.today > 7

    errors.add(:end_date, I18n.t('activerecord.errors.
                                   messages.end_date_more_7_days'))
  end

  def check_at_least_one_airport_type
    if  small_airport == false &&
        medium_airport == false &&
        large_airport == false
      errors.add('Airport type:',
                 I18n.t('activerecord.errors.messages
                        .check_at_least_one_airport_type'))
    end
  end

  def check_at_least_one_poi_selected
    if  proxy_food == false &&
        proxy_beverage == false &&
        proxy_fuel_car == false &&
        fuel_station_100ll == false &&
        fuel_station_91ul == false &&
        fuel_station_mogas == false &&
        charging_station == false &&
        proxy_car_rental == false &&
        proxy_bike_rental == false &&
        proxy_camp_site == false &&
        proxy_accommodation == false &&
        proxy_shop == false &&
        proxy_bus_station == false &&
        proxy_train_station == false &&
        proxy_hiking_path == false &&
        proxy_coastline == false &&
        proxy_lake == false
      errors.add(I18n.t('activerecord.attributes.trip_request.proxy_groups'),
                 I18n.t('activerecord.errors.messages
                          .check_at_least_one_poi_selected'))
    end
  end
end
