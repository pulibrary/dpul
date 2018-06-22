module ApplicationHelper
  include Blacklight::BlacklightHelperBehavior
  include Spotlight::ApplicationHelper

  def site_sidebar?
    can?(:manage, Spotlight::Site.instance) || can?(:create, Spotlight::Exhibit)
  end
end
