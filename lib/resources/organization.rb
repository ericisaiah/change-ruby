module Change
  module Resources
    class Organization < MemberResource

      attr_accessor :petitions

      def initialize(client, properties = {})
        super(client, properties)
        @petitions = PetitionCollection.new(self)
      end
    end
  end
end
