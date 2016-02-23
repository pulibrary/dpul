class PlumEventProcessor
  class CreateProcessor < Processor
    def process
      exhibits.map do |exhibit|
        resource = IIIFResource.new(manifest_url: manifest_url, exhibit: exhibit)
        resource.save_and_index
      end.all?(&:present?)
    end
  end
end
