module Change
  module Resources
    class CollectionResource < Resource

      class << self

        # Overridden for special pluralizations
        def collection_name
          name = self.name.split('::').last.downcase
          name = name.match(/(.+)collection/)[1]
          "#{name}s"
        end

      end

      attr_accessor :parent_resource
      attr_accessor :collection

      def initialize(parent_resource, collection = nil, properties = {})
        @parent_resource = parent_resource
        @collection = collection unless collection.nil?
        super(@parent_resource.client, properties)
      end

      def load(params)
        @parent_resource.load_collection(self.class.collection_name.to_sym, params)
      end

    end
  end
end
