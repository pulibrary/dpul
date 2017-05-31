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
      content_tag(:li, value.html_safe, dir: value.dir)
    end

    content_tag(:ul) do
      safe_join tags
    end
  end

  def header
    fields = Array.wrap(view_config.title_field)
    f = fields.detect { |field| @document.has? field }
    f ||= @configuration.document_model.unique_key
    @document[f].to_sentence(field_config(f).separator_options)
    field_value(f, value: @document[f].map(&:html_safe))
  end

  def field_config(field)
    super.tap do |f|
      f.separator_options =
        {
          words_connector: field_value_separator,
          two_words_connector: field_value_separator,
          last_word_connector: field_value_separator
        }
    end
  end
end
