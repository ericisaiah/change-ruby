module Change
  module Resources
    class Petition < MemberResource

      attr_accessor :signatures
      attr_accessor :targets
      attr_accessor :reasons
      attr_accessor :updates

      def initialize(client, properties = {})
        super(client, properties)
        @signatures = SignatureCollection.new(self)
        @targets = TargetCollection.new(self)
        @reasons = ReasonCollection.new(self)
        @updates = UpdateCollection.new(self)
      end
    end
  end
end