module Change
  module Resources
    class MemberResource < Resource

      class << self

        # This is the Change.org name for the resource type. It
        # is automatically derived from the class name.
        #
        # @return [String] the name of the resource
        def member_name
          self.name.split('::').last.downcase
        end

        # This is the Change.org pluralized name for the resource type. While it
        # can be overridden in sub-classes for non-standard English
        # pluralizations, it is automatically derived from the class name.
        #
        # @return [String] the pluralized name of the resource
        def collection_name
          "#{self.name.split('::').last.downcase}s"
        end

      end

      # The unique Change.org ID of the resource.
      attr_accessor :id

      # The fields on the resource. The Change.org API documentation has the
      # full list of fields that may be returned for each resource.
      attr_accessor :properties

      def initialize(client, properties = {})
        @id = properties.delete(:id) || properties.delete("#{self.class.member_name}_id")
        super(client, properties)
      end

      # Shared resource requests

      # Retrieves the unique Change.org ID for the current resource by its
      # resource current URL.
      #
      # @param resource_url [String] the current Change.org URL of the resource
      # @return [Integer] the unique Change.org ID of the resource
      def get_id(resource_url)
        response = make_request(:collection, { :method => :get, :action => :get_id }, { "#{self.class.member_name}_url".to_sym => resource_url })
        response["#{self.class.member_name}_id"]
      end

      def load(resource_id_or_url = nil, params = {})
        if resource_id_or_url.is_a?(Integer)
          @id = resource_id_or_url
        elsif resource_id_or_url.is_a?(String)
          @id = get_id(resource_id_or_url)
        end
        raise "Missing resource ID." if @id.nil?
        response = make_request(:member, { :method => :get }, params)
        response.delete("#{self.class.member_name}_id")
        @properties = response
      end

      def load_collection(collection, params = {})
        response = make_request(:member, { :method => :get, :collection => collection }, params)
        if response.is_a?(Array)
          self.send(collection).collection = response
        else  
          self.send(collection).collection = response[collection.to_s]
        end
      end

    end
  end
end
