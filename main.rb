require 'httparty'
require 'json'

CRISP_WEBSITE_ID = '1b27675d-a76a-4967-bfdb-c8dc88f4aac5'
CRISP_IDENTIFIER = '8f9a6b4a-95f3-4b31-b134-7c06308879b6'
CRISP_SECRET_KEY = 'feade7c704b52a4e1e4ab01f4d4c689eecadc16e1e710f425f49a5e72d109dcb'

def get_session_ids(from_date, to_date)
  url = "https://api.crisp.chat/v1/website/#{CRISP_WEBSITE_ID}/conversations/list"
  headers = { 'X-Crisp-Tier' => 'plugin' }

  response = HTTParty.get(url, 
                          basic_auth: { username: CRISP_IDENTIFIER, password: CRISP_SECRET_KEY },
                          headers: headers,
                          query: { from_date: from_date, to_date: to_date })

  if response.success?
    parsed_response = JSON.parse(response.body)

    if parsed_response.is_a?(Hash) && parsed_response.has_key?('data')
      parsed_response['data'].map { |conv| conv['session_id'] }
    else
      puts "Error: 'data' key not found in API response"
      []
    end
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