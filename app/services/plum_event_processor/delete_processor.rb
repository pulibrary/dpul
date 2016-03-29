class PlumEventProcessor
  class DeleteProcessor < Processor
    def process
      IIIFResource.where(url: manifest_url).each do |resource|
        resource.to_solr.map { |x| x[:id] }.each do |id|
          index.delete_by_id id.to_s
          index.commit
        end
        resource.destroy
      end
      true
    end
  end
end
