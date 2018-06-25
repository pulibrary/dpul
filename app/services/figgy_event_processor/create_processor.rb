class FiggyEventProcessor
  class CreateProcessor < Processor
    def process
      exhibits.map do |exhibit|
        resource = IIIFResource.new(url: manifest_url, exhibit: exhibit)
        resource.save_and_index
      end.all?(&:present?)
    end
  end
end
