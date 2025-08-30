Geocoder.configure(
  # Use OpenStreetMap's free Nominatim API
  lookup: :nominatim,
  
  # Be respectful with requests (required by Nominatim)
  timeout: 5,
  
  # Philippines-specific settings
  params: {
    countrycodes: 'ph',  # Limit results to Philippines
    addressdetails: 1,   # Get detailed address components
    format: 'json'
  },
  
  # Cache results to avoid repeated API calls
  cache: Rails.cache,
  cache_prefix: 'geocoder:'
)