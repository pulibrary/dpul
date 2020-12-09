# frozen_string_literal: true

class ExhibitsController < Spotlight::ExhibitsController
  delegate :_routes, to: :spotlight
  prepend_before_action :find_exhibit
  after_action :ingest_members, only: :create

  def ingest_members
    return unless @exhibit.persisted?

    ExhibitProxy.new(@exhibit).reindex
  end

  def destroy
    @exhibit.resources.destroy_all
    super
  end

  protected

    def exhibit_params
      params.require(:exhibit).permit(
        :title,
        :subtitle,
        :description,
        :published,
        :tag_list,
        :thumbnails_enabled,
        :condensed_viewer,
        contact_emails_attributes: %i[id email],
        languages_attributes: %i[id public]
      )
    end

  private

    def find_exhibit
      @exhibit ||=
        if params[:id]
          Spotlight::Exhibit.find(params[:id])
        else
          decorate(
            Spotlight::Exhibit.new
          )
        end
    end

    def decorate(obj)
      AppliesTitleFromSlug.new(obj, params[:exhibit][:slug])
    end
end
