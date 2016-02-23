class PlumEventProcessor
  class DeleteProcessor < Processor
    def process
      IIIFResource.where(url: manifest_url).each do |resource|
        index.delete_by_id resource.id.to_s
        index.commit
        resource.destroy
      end
      true
    end
  end
end
