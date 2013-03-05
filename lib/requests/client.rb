module Change
  module Requests
    class Client
      include HTTParty
      include Change::Exceptions

      def initialize(properties = {})
        @api_key = properties.delete(:api_key)
        @secret_token = properties.delete(:secret_token)
        raise "An API key must be specified." if @api_key.nil?
      end

      def request(request_on, request_type, resource, params)
        method = request_type.delete(:method)
        action_or_collection = request_type.delete(:action) || request_type.delete(:collection)
        endpoint = resource.endpoint(request_on, action_or_collection)

        params[:api_key] = @api_key

        if resource.needs_request_signature?(method)
          params[:endpoint] = endpoint
          params[:timestamp] = Time.now.utc.iso8601

          if resource.needs_authorization?(action_or_collection)
            auth_key_to_use = params.delete(:auth_key_to_use) || resource.auth_key
            params[:rsig] = generate_rsig(params, auth_key_to_use['auth_key'])
          else
            params[:rsig] = generate_rsig(params)
          end
        end

        response = send(method.to_s, final_url(endpoint), params)
        deal_with_response(response)
      end

      private

      def deal_with_response(response)
        case response.code
        when 200, 202
          response.parsed_response
        else
          messages = if response.code == 500
            ['A server error has occurred.']
          else
            response.parsed_response['messages']
          end

          raise ChangeException.new(messages, response.code), messages.join(' '), caller
        end
      end

      def base_url
        "https://#{Change::HOST}"
      end

      def final_url(endpoint)
        base_url + endpoint
      end

      def get(url, params)
        HTTParty.get(url, { :query => params })
      end

      def post(url, params)
        HTTParty.post(url, { :body => params })
      end

      def generate_rsig(params, auth_key = nil)
        body_to_digest = "#{post_body(params)}#{@secret_token}#{auth_key}"
        Digest::SHA2.hexdigest(body_to_digest)
      end

      def post_body(params)
        HTTParty::HashConversions.to_params(params)
      end

    end
  end
end
