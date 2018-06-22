require 'rails_helper'

RSpec.describe FiggyEventHandler do
  subject(:handler) { described_class.new }

  describe "#work" do
    before do
      # I hate stubbing the object under test, but I'm not sure how to stop it
      #   from touching Rabbit..
      allow(handler).to receive(:ack!)
      allow(handler).to receive(:reject!)
    end
    let(:msg) do
      {
        "event" => "CREATED"
      }
    end
    it "sends the message to the FiggyEventProcessor as a hash" do
      figgy_event_processor = instance_double(FiggyEventProcessor, process: true)
      allow(FiggyEventProcessor).to receive(:new).and_return(figgy_event_processor)

      handler.work(msg.to_json)

      expect(figgy_event_processor).to have_received(:process)
      expect(FiggyEventProcessor).to have_received(:new).with(msg)
      expect(handler).to have_received(:ack!)
    end
    it "acknowleges the message if the event is unknown" do
      figgy_event_processor = instance_double(FiggyEventProcessor, process: false)
      allow(FiggyEventProcessor).to receive(:new).and_return(figgy_event_processor)

      handler.work(msg.to_json)

      expect(figgy_event_processor).to have_received(:process)
      expect(FiggyEventProcessor).to have_received(:new).with(msg)
      expect(handler).to have_received(:ack!)
    end
  end
end
