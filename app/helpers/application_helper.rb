# frozen_string_literal: true

module ApplicationHelper
  include Blacklight::BlacklightHelperBehavior
  include Spotlight::ApplicationHelper
  delegate :url, to: :universal_viewer, prefix: true

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
    current_site.title || t("blacklight.application_name")
  end
  alias application_name header_title

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

  # Retrieve the thumbnail using the SolrDocument
  # @param document [SolrDocument]
  # @param image_options [Hash]
  # @return [Array<String>] an Array containing the URLs to the thumbnails
  def document_thumbnail(document, image_options = {})
    return unless !current_exhibit.nil? && current_exhibit.thumbnails_enabled && !universal_viewer(document).nil?

    values = document.fetch(:thumbnail_ssim, nil)
    return if values.empty?

    url = values.first
    image_tag url, image_options if url.present?
  end

  # Gives the bookmarks path by document id instead of access id
  # Use as an alternative to bookmark_path
  def bookmarks_id_path(document)
    Pathname.new('/').join("bookmarks", document.id).to_s
  end

  private

    # Generate the URL for the configuration for the UV
    # @return [String]
    def universal_viewer_config_url(document = @document)
      url_base = Pomegranate.config["external_universal_viewer_config_url"]
      "#{url_base}?manifest=#{document.manifest}"
    end

    # Generate the URL for the UV viewer
    # @return [String]
    def universal_viewer_installation_url
      Pomegranate.config["external_universal_viewer_url"]
    end

    # Construct the object used to handle Universal Viewer installations
    # @return [UniversalViewer]
    def universal_viewer(document = @document)
      return if document.nil?

      UniversalViewer.new(
        universal_viewer_installation_url,
        manifest: document.manifest,
        config: universal_viewer_config_url(document)
      )
    end

    # Replace deprecated #should_autofocus_on_search_box?
    # method until we update views to use components.
    # https://github.com/projectblacklight/blacklight/blob/v7.19.2/app/helpers/blacklight/catalog_helper_behavior.rb#L213
    def autofocus_on_search_box?
      controller.is_a?(Blacklight::Catalog) &&
        action_name == "index" &&
        !has_search_parameters?
    end
end
