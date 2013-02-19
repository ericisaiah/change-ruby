require 'util/test_helper'

describe 'SignatureCollection' do

  describe '#auth_key' do

    before do
      client = mock
      @test_key = 'my_test_key'
      @parent_resource = Change::Resources::Petition.new(client, { :auth_key => { 'auth_key' => @test_key } })
      @signature_collection = Change::Resources::SignatureCollection.new(@parent_resource)
    end

    it "should return the parent resource's auth key" do
      @signature_collection.auth_key['auth_key'].must_equal @test_key
    end

  end

  describe '#add_signature' do

    before do
      @client = mock
      @params = {
          :first_name => 'Jean-Luc',
          :last_name => 'Picard',
          :city => 'Marseille',
          :postal_code => '13055',
          :country_code => 'FR',
          :email => 'jlp@enterprise1701d.com'
        }
    end

    describe "when there is already an auth key on the parent resource" do

      before do
        @test_key = 'my_test_key'
        @parent_resource = Change::Resources::Petition.new(@client, { :auth_key => { 'auth_key' => @test_key } })
        @signature_collection = Change::Resources::SignatureCollection.new(@parent_resource)
      end

      it "should post a signature to its parent petition and return true if successful" do
        @signature_collection.expects(:make_request)
          .with(:collection, { :method => :post }, @params)
          .returns({ 'result' => 'success' })
        @signature_collection.add_signature(@params).must_equal true
      end

      it "should post a signature to its parent petition and return false if unsuccessful" do
        @signature_collection.expects(:make_request)
          .with(:collection, { :method => :post }, @params)
          .returns({ 'result' => 'failure' })
        @signature_collection.add_signature(@params).must_equal false
      end

    end

    describe "when there is no auth key on the parent resource" do

      before do
        @parent_resource = Change::Resources::Petition.new(@client)
        @signature_collection = Change::Resources::SignatureCollection.new(@parent_resource)
      end

      it "should raise an error when trying to post a signature" do
        @signature_collection.expects(:make_request).never
        lambda { @signature_collection.add_signature(@params) }.must_raise(RuntimeError)
      end

      it "should succeed in adding a signature if an auth key is specified during the call" do
        on_call_auth_key = {
          'auth_key' => 'my_on_call_auth_key',
          'source' => 'my_source'
        }
        @signature_collection.expects(:make_request)
          .with(:collection, { :method => :post }, @params)
          .returns({ 'result' => 'success' })
        @signature_collection.add_signature(@params, on_call_auth_key).must_equal true
      end
    end

  end
end
