module Geocodable
  extend ActiveSupport::Concern

  included do
    geocoded_by :location
    after_validation :geocode_and_extract_details, if: :location_changed?
  end

  def location_display
    return location if city.blank? && province.blank?
    [city, province].compact.join(', ')
  end

  private

  def geocode_and_extract_details
    return if location.blank?
    
    # Try multiple search strategies to get the best result
    result = find_best_geocoding_result
    
    if result
      # Set coordinates
      self.latitude = result.latitude
      self.longitude = result.longitude
      
      # Extract city/province from the geocoding result
      self.city = extract_city_name(result)
      self.province = extract_province_name(result)
    end
  end
  
  def find_best_geocoding_result
    # Trying different search strategies
    search_queries = [
      location,  # Original search
    ]
    
    # If location contains "City", try without "City" suffix
    if location.include?("City")
      clean_location = location.gsub(/ City/, '').strip
      search_queries << "#{clean_location}, Philippines"
    end
    
    # Try each search query and find the best administrative result
    search_queries.each do |query|
      results = Geocoder.search(query)
      
      # Prefer administrative/city results over specific locations
      administrative_result = results.find { |r| r.type == 'administrative' }
      return administrative_result if administrative_result
      
      # If no administrative result, try to find city-level results
      city_result = results.find { |r| r.type == 'city' }
      return city_result if city_result
    end
    
    # Fall back to the first result from original search
    Geocoder.search(location).first
  end
  
  def extract_city_name(result)
    # Try to get the most specific city/municipality name
    # Priority: city -> municipality -> town -> village -> suburb
    city_name = result.city || 
                result.town || 
                result.municipality || 
                result.village ||
                result.suburb
                
    # For Philippines Metro Manila cities, sometimes they're in display_name
    if city_name.blank? && result.display_name.present?
      # Extract city from display_name (e.g., "Makati, Metro Manila, Philippines")
      parts = result.display_name.split(',').map(&:strip)
      if parts.length >= 2
        # First part is usually the most specific location
        potential_city = parts[0]
        # Check if it contains "City" or is a known Metro Manila city
        if potential_city.include?('City') || metro_manila_cities.include?(potential_city)
          city_name = potential_city
        end
      end
    end
    
    city_name
  end
  
  def extract_province_name(result)
    # Try to get province/state
    province_name = result.state || result.province
    
    # For Metro Manila, standardize the name
    if province_name == "National Capital Region" || 
       province_name == "NCR" || 
       result.display_name&.include?("Metro Manila")
      province_name = "Metro Manila"
    end
    
    province_name
  end
  
  def metro_manila_cities
    [
      'Manila', 'Quezon City', 'Makati', 'Pasig', 'Taguig', 'Mandaluyong',
      'Marikina', 'Pasay', 'Las Piñas', 'Muntinlupa', 'Parañaque',
      'Valenzuela', 'Malabon', 'Navotas', 'Caloocan', 'San Juan', 'Pateros'
    ]
  end
end