Geocoder.configure(
  # OpenStreetMap's free Nominatim API
  lookup: :nominatim,
  
  # Request Timeouts (limits) (required by Nominatim)
  timeout: 10,
  
  # Philippines-specific settings
  params: {
    countrycodes: 'ph',  # Limit results to Philippines
    addressdetails: 1,   # Get detailed address components
    format: 'json',
    limit: 1,            
    'accept-language': 'en' # Get English results
  },
  
  # Cache results to avoid repeated API calls
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  
  # Units for distance calculations
  units: :km,
  
  # HTTP headers
  http_headers: {
    "User-Agent" => "ServicePH Rails App"
  }
)