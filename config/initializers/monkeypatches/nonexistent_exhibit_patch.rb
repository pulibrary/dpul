# frozen_string_literal: true

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
