# frozen_string_literal: true

namespace :dpul do
  namespace :cleanup do
    desc "delete duplicate sidecars"
    task sidecars: :environment do
      config = CatalogController.blacklight_config
      repo = FriendlyIdRepository.new(config)
      dups = Spotlight::SolrDocumentSidecar.select(:exhibit_id, :document_id).group(:exhibit_id, :document_id).having("count(*) > 1").size.keys

      dup_sets = dups.map do |exhibit_id, document_id|
        Spotlight::SolrDocumentSidecar.where(exhibit_id: exhibit_id, document_id: document_id).to_a
      end

      # alternative strategy
      dup_sets.each do |ds|
        puts "solr document: #{ds.first.document_id}"
        # for each set, create a solr document
        document = SolrDocument.new(repo.search(q: "id:#{ds.first.document_id}")["response"]["docs"].first)

        # delete the ones that we can't get to from that document
        # see for example
        # https://github.com/pulibrary/dpul/blob/09547ac7e7d9a21dc5b8dbc5437039e936e0d76f/app/views/spotlight/catalog/_edit_default.html.erb#L7
        sidecar_to_keep = document.sidecar(ds.first.exhibit_id)
        puts "  keeping sidecar last updated at #{sidecar_to_keep.updated_at}"

        sidecars_to_delete = ds - [sidecar_to_keep]
        sidecars_to_delete.each do |sidecar|
          if sidecar.resource_id
            r = Spotlight::Resource.find(sidecar.resource_id)
            puts "  deleting resource #{r.id}, sidecar last updated at #{sidecar.updated_at}"
            # r.destroy
          else # sidecar resource_id was nil
            puts "  deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
            # sidecar.destroy
          end
        end
      end

      # Original strategy
      #
      # dup_sets.each do |ds|
      #   puts "solr document: #{ds.first.document_id}"
      #   # for each set, if any sidecar has resource_id nil, delete that sidecar
      #   linked_sidecars = ds.reject { |sidecar| sidecar.resource_id.nil? }
      #   ds.select { |sidecar| sidecar.resource_id.nil? }.each do |sidecar|
      #     puts " deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
      #     # sidecar.destroy
      #   end
      #
      #   # otherwise, get the solr document and see which resource_id it references
      #   next unless linked_sidecars.count > 1
      #
      #   doc = repo.search(q: "id:#{linked_sidecars.first.document_id}")["response"]["docs"].first
      #   good_resource_id = doc["spotlight_resource_id_ssim"].first.split("/").last
      #   sidecars_to_delete = linked_sidecars.reject do |sidecar|
      #     sidecar.resource_id == good_resource_id
      #   end
      #   # delete the other resource and sidecar (which may happen automatically
      #   # when resource is deleted?)
      #   sidecars_to_delete.each do |sidecar|
      #     r = Spotlight::Resource.find(sidecar.resource_id)
      #     puts " deleting resource #{r.id}, sidecar last updated at #{sidecar.updated_at}"
      #     # r.destroy
      #   end
      #   sidecar_to_keep = linked_sidecars.find do |sidecar|
      #     sidecar.resource_id == good_resource_id
      #   end
      #   puts " keeping sidecar last updated at #{sidecar_to_keep.updated_at}"
      # end
    end
  end
end
