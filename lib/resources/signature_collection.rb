module Change
  module Resources
    class SignatureCollection < CollectionResource

      def auth_key
        @parent_resource.auth_key
      end

      def add_signature(params = {}, auth_key_to_use = nil)
        auth_key_to_use ||= auth_key
        params[:auth_key_to_use] = auth_key_to_use
        params[:source] = auth_key_to_use['source']
        response = make_request(:collection, { :method => :post }, params)
        response['result'] == 'success'
      end
    end
  end
end
