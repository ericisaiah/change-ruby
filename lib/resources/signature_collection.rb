module Change
  module Resources
    class SignatureCollection < CollectionResource

      def auth_key
        @parent_resource.auth_key
      end

      def add_signature(params)
        response = make_request(:collection, { :method => :post }, params)
        response['result'] == 'success'
      end
    end
  end
end
