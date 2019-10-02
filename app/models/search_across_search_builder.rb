# frozen_string_literal: true

class SearchAcrossSearchBuilder < ::SearchBuilder
  self.default_processor_chain += [:hide_unpublished_exhibit_records, :hide_private_exhibit_records]

  def hide_unpublished_exhibit_records(solr_params)
    solr_params[:fq] ||= []
    Spotlight::Exhibit.unpublished.each do |exhibit|
      next if scope.can?(:curate, exhibit)
      solr_params[:fq] << "!spotlight_exhibit_slug_#{exhibit.slug}_bsi:true"
    end
  end

  def hide_private_exhibit_records(solr_params)
    solr_params[:fq] ||= []
    Spotlight::Exhibit.all.find_each do |exhibit|
      next if scope.can?(:curate, exhibit)
      solr_params[:fq] << "!#{blacklight_config.document_model.visibility_field(exhibit)}:false"
    end
  end
end
