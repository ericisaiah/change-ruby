module Change
  module Resources
    class MemberResource < Resource

      class << self

        def member_name
          self.name.split('::').last.downcase
        end

        # Overridden for special pluralizations
        def collection_name
          "#{self.name.split('::').last.downcase}s"
        end

      end

      attr_accessor :id
      attr_accessor :properties

      def initialize(client, properties = {})
        @id = properties.delete(:id) || properties.delete("#{self.class.member_name}_id")
        super(client, properties)
      end

      # Shared resource requests

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
