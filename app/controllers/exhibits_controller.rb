class ExhibitsController < Spotlight::ExhibitsController
  prepend_before_action :find_exhibit

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
