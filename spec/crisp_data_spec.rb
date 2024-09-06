require_relative '../main.rb' # Adjust the path if needed

RSpec.describe '#get_conversation_ids' do
  # Replace with actual values or use environment variables for sensitive data
  let(:crisp_website_id) { 'y1b27675d-a76a-4967-bfdb-c8dc88f4aac5' }
  let(:crisp_identifier) { '8f9a6b4a-95f3-4b31-b134-7c06308879b6' }
  let(:crisp_secret_key) { 'feade7c704b52a4e1e4ab01f4d4c689eecadc16e1e710f425f49a5e72d109dcb' }

  # Mock the HTTParty response for testing
  before do
    allow(HTTParty).to receive(:get).and_return(double(
      success?: true,
      body: '[{"session_id": "session_123"}, {"session_id": "session_456"}]'
    ))
  end

  it 'returns an array of conversation IDs' do
    from_date = 1690867200000
    to_date = 1693545600000
    conversation_ids = get_conversation_ids(from_date, to_date)
    expect(conversation_ids).to eq(["session_123", "session_456"])
  end

  # Add more test cases for different scenarios:
  # - Error responses from the API
  # - Empty response (no conversations)
  # - ...
end