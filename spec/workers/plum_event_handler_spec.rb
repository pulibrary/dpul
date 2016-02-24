require 'rails_helper'

RSpec.describe PlumEventHandler do
  subject { described_class.new }

  describe "#work" do
    before do
      # I hate stubbing the object under test, but I'm not sure how to stop it
      #   from touching Rabbit..
      allow(subject).to receive(:ack!)
      allow(subject).to receive(:reject!)
    end
    let(:msg) do
      {
        "event" => "CREATED"
      }
    end
    it "sends the message to the PlumEventProcessor as a hash" do
      plum_event_processor = instance_double(PlumEventProcessor, process: true)
      allow(PlumEventProcessor).to receive(:new).and_return(plum_event_processor)

      subject.work(msg.to_json)

      expect(plum_event_processor).to have_received(:process)
      expect(PlumEventProcessor).to have_received(:new).with(msg)
      expect(subject).to have_received(:ack!)
    end
    it "rejects the message if the processing fails" do
      plum_event_processor = instance_double(PlumEventProcessor, process: false)
      allow(PlumEventProcessor).to receive(:new).and_return(plum_event_processor)

      subject.work(msg.to_json)

      expect(plum_event_processor).to have_received(:process)
      expect(PlumEventProcessor).to have_received(:new).with(msg)
      expect(subject).to have_received(:reject!)
    end
  end
end
