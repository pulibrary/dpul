module ApplicationHelper
  include Blacklight::BlacklightHelperBehavior
  include Spotlight::ApplicationHelper

  def site_sidebar?
    can?(:manage, Spotlight::Site.instance) || can?(:create, Spotlight::Exhibit)
  end

  # site_title pulls from the db if configured through the UI.
  #   otherwise use the val from the blacklight locale file.
  #   We need this because application_name helper changes to include exhibit titles
  def header_title
    site_title || t("blacklight.application_name")
  end

  def current_year
    DateTime.now.year
  end
end
