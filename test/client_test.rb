require 'util/test_helper'

describe 'Client' do

  before do
    @api_key_example = 'goodbye_world'
    @secret_token_example = 'hello_world'
    @client = Change::Requests::Client.new({
      :api_key => @api_key,
      :secret_token => @secret_token_example
    })
  end

  describe '#request' do

    it "should make a request on a resource with the specified method, request type, and params"

  end

end
