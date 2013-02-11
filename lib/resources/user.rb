module Change
  module Resources
    class User < MemberResource

      attr_accessor :petitions
      attr_accessor :signatures_on_petitions

      def initialize(client, properties = {})
        super(client, properties)
        @petitions = PetitionCollection.new(self)
        @signatures_on_petitions = PetitionCollection.new(self)
      end

    end
  end
end