class RTLIndexPresenter < ::Blacklight::IndexPresenter
  # Override the IndexPresenter label method to render
  # the label as an Array if it's multivalued.
  def label(field_or_string_or_proc, opts = {})
    config = Blacklight::Configuration::NullField.new
    value = case field_or_string_or_proc
            when Symbol
              config = field_config(field_or_string_or_proc)
              value_from_symbol(field_or_string_or_proc)
            when Proc
              field_or_string_or_proc.call(@document, opts)
            when String
              field_or_string_or_proc
            end
    value ||= @document.id
    label_value(value, config)
  end

  private

    # Checks if the requested field is the title field and if the configured
    # display title field exists on the document. If so, it returns the
    # display title field value. This method allows pom to properly display
    # records with non-standard title fields.
    def value_from_symbol(field)
      default_title_field = @configuration.index.title_field.to_sym
      display_title_field = @configuration.index.display_title_field.to_sym

      if field == default_title_field && @document.key?(display_title_field)
        @document[display_title_field]
      else
        @document[field]
      end
    end

    def label_value(value, config)
      if value.is_a?(Array) && value.count > 1
        value.collect { |v| field_values(config, value: v.html_safe) }
      else
        field_values(config, value: Array.wrap(value).map(&:html_safe))
      end
    end
end
