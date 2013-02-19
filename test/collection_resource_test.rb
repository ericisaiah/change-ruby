require 'util/test_helper'

class TesterCollection < Change::Resources::CollectionResource; end
class TesterMember < Change::Resources::MemberResource
  attr_accessor :testers

  def initialize(client, properties = {})
    super(client, properties)
    @testers = TesterCollection.new(self)
  end

end

describe 'CollectionResource' do

  describe '#collection_name' do

    it "should derive the collection name from the class name before 'Collection'" do
      correct_collection_name = "testers"
      TesterCollection.collection_name.must_equal correct_collection_name
    end

  end

  describe '#initialize' do

    it "should initialize the resource with the specified parent resource and set the client to that of the parent" do
      auth_key = { :auth_key => 'a test' }
      client = mock
      parent_resource = TesterMember.new(client)
      resource = TesterCollection.new(parent_resource)
      resource.parent_resource.must_equal parent_resource
      resource.client.must_equal client
    end

  end

  describe 'after initialization' do

    before do
      @client = mock
      @parent_resource = TesterMember.new(@client)
      @resource = TesterCollection.new(@parent_resource)
    end

    describe '#load' do

      it "should load the collection using the parent resource" do
        params = { :param1 => 1}
        returned_collection = [1, 2]
        collection_name = TesterCollection.collection_name.to_sym
        @parent_resource.expects(:load_collection).with(collection_name, params).once
        @resource.load(params)
      end

    end

  end

end
