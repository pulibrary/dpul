# frozen_string_literal: true

# overrides upstream function at
# https://github.com/projectblacklight/spotlight/blob/b0ec1859deff30aed794eb33a49f3ad830c4e6ea/app/controllers/spotlight/pages_controller.rb#L177
# to 404 if the exhibit doesn't exist
Rails.application.config.to_prepare do
  module NonexistentExhibitPatch
    def load_locale_specific_page
      if current_exhibit
        @page = current_exhibit.pages.for_locale.find(params[:id])
      else
        not_found
      end
    rescue ActiveRecord::RecordNotFound
      redirect_page_to_related_locale_version
    end
  end

  Spotlight::PagesController.prepend(NonexistentExhibitPatch)
end
