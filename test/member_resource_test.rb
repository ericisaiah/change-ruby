require 'util/test_helper'

class WidgetsCollection < Change::Resources::CollectionResource; end
class TesterResource < Change::Resources::MemberResource

  attr_accessor :widgets

  def initialize(client, properties = {})
    super(client, properties)
    @widgets = WidgetsCollection.new(self)
  end
end

describe 'MemberResource' do

  describe '#initialize' do

    it "should initialize the resource with id, properties, and an auth key if specified" do
      auth_key = { :auth_key => 'a test' }
      properties = { :id => 3, :auth_key => auth_key, :other => 'what' }
      resource_with_auth_key = TesterResource.new(@client, properties)
      resource_with_auth_key.auth_key.must_equal auth_key
      resource_with_auth_key.id.must_equal 3
      resource_with_auth_key.properties[:other].must_equal 'what'
    end

  end

  describe 'after initialization' do

    before do
      @client = mock
      @resource = TesterResource.new(@client)
    end

    describe '#needs_authorization?' do

      it "should return true for :get" do
        @resource.needs_authorization?(:get).must_equal false
      end

      it "should return false for :post, :put, and :delete" do
        @resource.needs_authorization?(:post).must_equal true
        @resource.needs_authorization?(:put).must_equal true
        @resource.needs_authorization?(:delete).must_equal true
      end

    end

    describe '#auth_key' do

      before do
        @test_key_1 = { :auth_key => 'test_key', :source => 'test source' }
        @test_key_2 = { :auth_key => 'test_key2', :source => 'test source 2' }
      end

      it "should add a new auth key to the resource and return the first one or a specific one" do
        @resource.auth_key = @test_key_1
        @resource.auth_key.must_equal @test_key_1

        @resource.auth_key = @test_key_2
        @resource.auth_key.must_equal @test_key_1
        @resource.auth_key(1).must_equal @test_key_2
      end

    end

    describe '#make_request' do

      before do
        @resource.id = 1
        @request_on = :member
        @request_type = { :method => :get }
        @params = {}
      end

      it "should make a call to its client's request method" do
        @client.expects(:request).with(@request_on, @request_type, @resource, @params).once
        @resource.make_request(@request_on, @request_type, @params)
      end

    end

    describe '#endpoint' do

      before do
        @resource.id = 2
      end

      it "should return a proper endpoint path for a specific member" do
        @resource.endpoint(:member).must_equal '/v1/testerresources/2'
      end

      it "should return a proper endpoint path for a sub-collection of a specific member" do
        @resource.endpoint(:member, :petitions).must_equal '/v1/testerresources/2/petitions'
      end

      it "should return a proper endpoint path for resource collection" do
        @resource.endpoint(:collection).must_equal '/v1/testerresources'
      end
    end

    describe '#request_auth_key' do

      it "should return true if an auth key is granted" do
        @resource.expects(:make_request)
          .with(:member, { :method => :post, :collection => :auth_keys }, {})
          .returns({ 'status' => 'granted', 'api_key' => "test" })
        @resource.request_auth_key({}).must_equal true
      end

      it "should return false if an auth key is not granted" do
        @resource.expects(:make_request)
          .with(:member, { :method => :post, :collection => :auth_keys }, {})
          .returns({ 'status' => 'denied', 'api_key' => "test" })
        @resource.request_auth_key({}).must_equal false
      end

    end

    describe '#get_id' do

      it "should make a request to get the ID of the resource by URL" do
        resource_url = "http://www.change.org/petitions/i-am-a-url"
        @resource.expects(:make_request)
          .with(:collection, { :method => :get, :action => :get_id }, { "#{TesterResource.member_name}_url".to_sym => resource_url })
          .returns({ "#{TesterResource.member_name}_id" => 1 })
        @resource.get_id(resource_url).must_equal 1
      end

    end

  end

  describe '#load' do

    before do
      @client = mock
      @resource = TesterResource.new(@client)
    end

    it "should load the resource by ID" do
      res_id = 3
      params = {}
      @resource.expects(:get_id).never
      @resource.expects(:make_request)
        .with(:member, { :method => :get }, params)
        .returns({
          'name' => "John",
          'age' => 43
          })
      @resource.load(res_id)
      @resource.id.must_equal 3
      @resource.properties['name'].must_equal "John"
      @resource.properties['age'].must_equal 43
    end

    it "should load the resource by URL" do
      resource_url = 'http://www.change.org/petitions/example'
      params = {}
      @resource.expects(:get_id).with(resource_url).returns(93)
      @resource.expects(:make_request)
        .with(:member, { :method => :get }, params)
        .returns({
          'name' => "Billy Jo",
          'age' => 8
          })
      @resource.load(resource_url)
      @resource.id.must_equal 93
      @resource.properties['name'].must_equal "Billy Jo"
      @resource.properties['age'].must_equal 8
    end

  end

  describe '#load_collection' do

    before do
      @client = mock
      @resource = TesterResource.new(@client)
      @params = {}
      @returned_widgets = [1, 3, 5, 7]
    end

    it "should load collection by dumping the returned array if that's what is returned" do
      @resource.widgets.collection.must_be_nil
      @resource.expects(:make_request)
        .with(:member, { :method => :get, :collection => :widgets }, @params)
        .returns(@returned_widgets)
      @resource.load_collection(:widgets)
      @resource.widgets.collection.must_equal @returned_widgets
    end

    it "should load collection by getting the matching object attribute and dumping that array" do
      @resource.widgets.collection.must_be_nil
      @resource.expects(:make_request)
        .with(:member, { :method => :get, :collection => :widgets }, @params)
        .returns({
          'an_attr' => 'something',
          'name' => 'hello',
          'widgets' => @returned_widgets
        })
      @resource.load_collection(:widgets)
      @resource.widgets.collection.must_equal @returned_widgets
    end

  end
end
