# frozen_string_literal: true

class FiggyEventProcessor
  class CreateProcessor < Processor
    def process
      exhibits.map do |exhibit|
        resource = IiifResource.new(url: manifest_url, exhibit:)
        resource.save_and_index
      end.all?(&:present?)
    end
  end
end
