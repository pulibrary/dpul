class ExhibitsController < Spotlight::ExhibitsController
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

  private

    def find_exhibit
      @exhibit ||=
        decorate(
          Spotlight::Exhibit.new
        )
    end

    def decorate(obj)
      AppliesTitleFromSlug.new(obj, params[:exhibit][:slug])
    end
end
