class RTLShowPresenter < ::Blacklight::ShowPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def field_value_separator
    tag('br')
  end

  ##
  # Render the show field value for a document
  #
  #   Allow an extention point where information in the document
  #   may drive the value of the field
  #   @param [String] field
  #   @param [Hash] options
  #   @options opts [String] :value
  def field_value(field, options = {})
    tags = super.split(field_value_separator).collect do |value|
      content_tag(:li, value, dir: value.dir)
    end

    content_tag(:ul) do
      safe_join tags
    end
  end
end
