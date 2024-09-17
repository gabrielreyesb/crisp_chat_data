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

def save_all_user_messages_to_file(session_ids)
  File.open("all_user_messages.txt", 'w') do |file|
    session_ids.each do |session_id|
      messages = get_session_messages(session_id)
      if messages.is_a?(Hash) && messages['data'].is_a?(Array)
        file.puts "Session ID: #{session_id}"
        messages['data'].each do |msg|
          if msg.is_a?(Hash) && msg['type'] == 'text' && msg['from'] == 'user'
            file.puts(msg['content'])
          end
        end
        file.puts
      else
        puts "No valid messages found for session #{session_id}"
      end
    end
  end
end

offset = -6 * 3600
date = Time.new(2024, 9, 16)

from_date = Time.new((date + offset).year, (date + offset).month, (date + offset).day, 0, 0, 0).to_i * 1000  # Start of the day in Unix timestamp milliseconds
to_date = Time.new((date + offset).year, (date + offset).month, (date + offset).day, 23, 59, 59).to_i * 1000  # End of the day in Unix timestamp milliseconds

puts "From Date: #{Time.at(from_date / 1000).utc.strftime('%Y-%m-%d %H:%M:%S')} UTC"
puts "To Date: #{Time.at(to_date / 1000).utc.strftime('%Y-%m-%d %H:%M:%S')} UTC"

session_ids = get_session_ids(from_date, to_date)

session_ids.each do |session_id|
  save_all_user_messages_to_file(session_ids)
end