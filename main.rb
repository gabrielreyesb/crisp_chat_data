require 'httparty'
require 'json'

CRISP_WEBSITE_ID = '1b27675d-a76a-4967-bfdb-c8dc88f4aac5'
CRISP_IDENTIFIER = '09640e77-73ad-4379-9bd4-7168f5f97705' 
CRISP_SECRET_KEY = '8735a607b4e5ffff157004f56e9b5bdcab5d43d943d86b2597d141da16664abf' 

def get_session_ids(from_date, to_date)
  url = "https://api.crisp.chat/v1/website/#{CRISP_WEBSITE_ID}/conversations/list"
  headers = { 'X-Crisp-Tier' => 'plugin' }

  response = HTTParty.get(url, 
                          basic_auth: { username: CRISP_IDENTIFIER, password: CRISP_SECRET_KEY },
                          headers: headers,
                          query: { from_date: from_date, to_date: to_date })

  puts "Response Code: #{response.code}"  # Debugging output
  puts "Response Body: #{response.body}"  # Debugging output

  if response.success?
    parsed_response = JSON.parse(response.body)

    if parsed_response.is_a?(Hash) && parsed_response.has_key?('data')
      parsed_response['data'].map { |conv| conv['session_id'] }
    else
      puts "Error: 'data' key not found in API response"
      return []
    end
  else
    puts "Error fetching session IDs: #{response.code} - #{response.body}"
    return []
  end
end

def get_session_messages(session_id)
  url = "https://api.crisp.chat/v1/website/#{CRISP_WEBSITE_ID}/conversation/#{session_id}/messages"

  headers = {'X-Crisp-Tier' => 'plugin'}

  response = HTTParty.get(url, 
                          basic_auth: { username: CRISP_IDENTIFIER, password: CRISP_SECRET_KEY },
                          headers: headers)

  if response.success?
    JSON.parse(response.body)
  else
    puts "Error fetching messages for conversation #{session_id}: #{response.code} - #{response.body}"
    []
  end
end

from_date = (Time.now - 24*60*60).to_i * 1000  # Yesterday in Unix timestamp milliseconds
to_date = Time.now.to_i * 1000                  # Now in Unix timestamp milliseconds

session_ids = get_session_ids(from_date, to_date)

session_ids.each do |session_id|
  messages = get_session_messages(session_id)
  puts "Session ID: #{session_id}"
  puts messages
  puts "----"
end