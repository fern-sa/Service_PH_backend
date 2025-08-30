module Geocodable
  extend ActiveSupport::Concern

  included do
    geocoded_by :location
    after_validation :geocode, if: :location_changed?
    after_validation :extract_location_details, if: :location_changed?
  end

  def location_display
    return location if city.blank? && province.blank?
    [city, province].compact.join(', ')
  end

  private

  def extract_location_details
    return unless latitude.present? && longitude.present?
    
    result = Geocoder.search([latitude, longitude]).first
    if result
      self.city = result.city || result.town || result.village
      self.province = result.state
    end
  end
end