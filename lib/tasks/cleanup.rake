# frozen_string_literal: true

# rubocop:disable
namespace :dpul do
  namespace :cleanup do
    desc "delete duplicate sidecars"
    task sidecars: :environment do
      logger = Logger.new(STDOUT)
      config = CatalogController.blacklight_config
      repo = FriendlyIdRepository.new(config)
      dups = Spotlight::SolrDocumentSidecar.select(:exhibit_id, :document_id).group(:exhibit_id, :document_id).having("count(*) > 1").size.keys

      dup_sets = dups.map do |exhibit_id, document_id|
        Spotlight::SolrDocumentSidecar.where(exhibit_id: exhibit_id, document_id: document_id).to_a
      end

      # alternative strategy
      dup_sets.each do |ds|
        logger.info "solr document: #{ds.first.document_id}"
        # for each set, create a solr document
        document_hash = repo.search(q: "id:#{ds.first.document_id}")["response"]["docs"].first

        # In staging there was a pair where one had a nil resource id and the
        # other referenced a resource that didn't exist in the db
        if document_hash.nil?
          logger.info "  solr document not found for resources #{ds.map(&:resource_id)}; sidecars #{ds.map(&:id)}"
          ds.each do |sidecar|
            if sidecar.resource_id
              # the resource referenced doesn't exist any longer
              if Spotlight::Resource.where(id: sidecar.resource_id).empty?
                logger.info "  deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
                # sidecar.destroy
              else # sidecar resource id was a real resource
                logger.info "  keeping sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
              end
            else
              # resource_id was nil
              logger.info "  deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
              # sidecar.destroy
            end
          end
          next
        end

        document = SolrDocument.new(document_hash)

        # delete the ones that we can't get to from that document
        # see for example
        # https://github.com/pulibrary/dpul/blob/09547ac7e7d9a21dc5b8dbc5437039e936e0d76f/app/views/spotlight/catalog/_edit_default.html.erb#L7
        sidecar_to_keep = document.sidecar(ds.first.exhibit_id)
        logger.info "  keeping sidecar #{sidecar_to_keep.id} last updated at #{sidecar_to_keep.updated_at}"

        sidecars_to_delete = ds - [sidecar_to_keep]
        sidecars_to_delete.each do |sidecar|
          if sidecar.resource_id
            if Spotlight::Resource.where(id: sidecar.resource_id).present?
              r = Spotlight::Resource.find(sidecar.resource_id)
              logger.info "  deleting resource #{r.id}, sidecar last updated at #{sidecar.updated_at}"
              # r.destroy
            else # the resource didn't exist
              logger.info "  deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
              # sidecar.destroy
            end
          else # sidecar resource_id was nil
            logger.info "  deleting sidecar #{sidecar.id}, last updated at #{sidecar.updated_at}"
            # sidecar.destroy
          end
        end
      end
    end
  end
end
# rubocop:enable
