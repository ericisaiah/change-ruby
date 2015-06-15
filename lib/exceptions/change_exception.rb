module Change
  module Exceptions
    class ChangeException < StandardError

      attr_reader :code
      attr_reader :messages

      def initialize(messages, code = nil)
        @code = code
        @messages = messages
      end

      def message
        @messages.first
      end
    end

    class PetitionNotFoundException < ChangeException ; end
  end
end
