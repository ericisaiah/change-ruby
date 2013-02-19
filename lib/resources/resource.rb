module Change
  module Resources
    class Resource

      attr_accessor :client

      def initialize(client, properties = {})
        @client = client
        @auth_keys = []

        initial_auth_key = properties.delete(:auth_key)
        add_new_auth_key(initial_auth_key) unless initial_auth_key.nil?
        @properties = properties
      end

      def make_request(request_on, request_type, params = {})
        @client.request(request_on, request_type, self, params)
      end

      def endpoint(request_on, action_or_collection = nil)
        path_parts = send("#{request_on.to_s}_path", action_or_collection)
        path = path_parts.join('/')
        path.prepend('/')
      end

      def needs_authorization?(method)
        method != :get
      end

      def auth_key(key_number = 0)
        @auth_keys[key_number]
      end

      def auth_key=(new_key)
        add_new_auth_key(new_key)
      end

      # Shared resource requests

      def request_auth_key(params)
        response = make_request(:member, { :method => :post, :collection => :auth_keys }, params)
        if response['status'] == 'granted'
          add_new_auth_key(response)
          true
        else
          false
        end
      end

      private

      def add_new_auth_key(key_object)
        key_object = { :auth_key => key_object } if key_object.is_a?(String)
        key_object.delete('status')
        key_object.delete('result')
        key_object.delete("#{self.class.member_name}_id")
        @auth_keys << key_object unless @auth_keys.include?(key_object)
      end

      def member_path(action_or_collection = nil)
        raise "Can't generate a member path without an ID." if @id.nil?
        path_parts = collection_path
        path_parts << @id
        path_parts << action_or_collection if action_or_collection
        path_parts
      end

      def collection_path(action = nil)
        path_parts = [Change::VERSION]
        if @parent_resource
          path_parts << @parent_resource.class.collection_name
          path_parts << @parent_resource.id
          path_parts << self.class.collection_name
        else
          path_parts << self.class.collection_name
          path_parts << action if action
        end
        path_parts
      end

    end
  end
end
