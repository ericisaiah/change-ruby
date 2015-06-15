require 'util/test_helper'

describe 'Client' do

  MockResponse = Struct.new("Response", :code, :parsed_response)

  before do
    @api_key_example = 'goodbye_world'
    @secret_token_example = 'hello_world'
    @client = Change::Requests::Client.new({
      :api_key => @api_key_example,
      :secret_token => @secret_token_example
    })
    @petition = Change::Resources::Petition.new(@client)
  end

  describe '#request' do

    it "should load a resource with a get request" do
      url_to_be_called = 'https://api.change.org/v1/petitions/1'
      params = { :api_key => @api_key_example }
      @client.expects(:send)
        .with('get', url_to_be_called, params)
        .once
        .returns(MockResponse.new(200, { "name" => "hey world" }))
      @petition.load(1)
      @petition.properties['name'].must_equal "hey world"
    end

    it "should modify a resource with a post request" do
      @petition.id = 2
      url_to_be_called = 'https://api.change.org/v1/petitions/2/signatures'
      params = {
        :api_key => @api_key_example,
        :first_name => 'Jean-Luc',
        :last_name => 'Picard',
        :city => 'Marseille',
        :postal_code => '13055',
        :country_code => 'FR',
        :email => 'jlp@enterprise1701d.com'
      }
      @client.expects(:send)
        .with('post', url_to_be_called, params)
        .once
        .returns(MockResponse.new(200, { "result" => "success" }))
      @petition.signatures.add_signature(params, { 'auth_key' => 'my_on_call_auth_key', 'source' => 'my_source' }).must_equal true
    end

    it "should raise an exception if the response indicates the request was not a successful" do
      url_to_be_called = 'https://api.change.org/v1/petitions/1'
      params = { :api_key => @api_key_example }
      @client.expects(:send)
        .with('get', url_to_be_called, params)
        .once
        .returns(MockResponse.new(400, { "result" => "failure", "messages" => [ "bad thing one", "bad thing two"] }))
      lambda { @petition.load(1) }.must_raise(Change::Exceptions::ChangeException)
    end

    it "should raise a typed exception if the response indicates the request was not a petition" do
      url_to_be_called = 'https://api.change.org/v1/petitions/1'
      params = { :api_key => @api_key_example }
      @client.expects(:send)
        .with('get', url_to_be_called, params)
        .once
        .returns(MockResponse.new(400, { "result" => "failure", "messages" => [ "petition not found"] }))
      lambda { @petition.load(1) }.must_raise(Change::Exceptions::PetitionNotFoundException)
    end

    it "should raise an exception if the response is a server error" do
      url_to_be_called = 'https://api.change.org/v1/petitions/1'
      params = { :api_key => @api_key_example }
      @client.expects(:send)
        .with('get', url_to_be_called, params)
        .once
        .returns(MockResponse.new(500, "<html>You broke me!</html>"))
      lambda { @petition.load(1) }.must_raise(Change::Exceptions::ChangeException)
    end

  end

  describe '#final_url' do

    it "should return the proper URL with the host and protocol" do
      @client.send(:final_url, '/v1/something').must_equal 'https://api.change.org/v1/something'
    end

  end

  describe '#generate_rsig' do

    it "should properly generate the request signature for the given body" do
      @petition.auth_key = { 'auth_key' => 'my_on_call_auth_key', 'source' => 'my_source' }
      params = { "first_arg" => "whatever is in the body" }
      to_digest = HTTParty::HashConversions.to_params(params) + @secret_token_example + @petition.auth_key['auth_key']
      expected_rsig = Digest::SHA2.hexdigest(to_digest)
      @client.send(:generate_rsig, params, @petition.auth_key['auth_key']).must_equal expected_rsig
    end
  end
end
