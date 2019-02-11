module ApplicationHelper
  include Blacklight::BlacklightHelperBehavior
  include Spotlight::ApplicationHelper
  delegate :url, to: :request, prefix: true

  def render_search_bar
    super
  rescue StandardError
    render partial: 'catalog/default_search_form'
  end

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
    Date.today.year
  end

  def text_area?(field, exhibit)
    index_field_config = exhibit.blacklight_config.index_fields[field.field]

    index_field_config.respond_to?(:text_area) && index_field_config.text_area == "1"
  end

  def text_area_value(field, sidecar)
    output = { data: [] }

    field_values = sidecar.data[field.field.to_s]
    return output.to_json if field_values.blank?

    field_values
  end

  def readonly?(field)
    custom_field = Spotlight::CustomField.find_by(field: field)
    return true if custom_field.nil?

    custom_field.readonly_field
  end
end
