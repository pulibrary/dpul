# Decorates a Custom Field to give an accessor for the alternate suffix.
class BothFields < SimpleDelegator
  def alternate_field
    field.gsub(/(.*)_.*$/, '\1' + alternate_field_suffix)
  end

  private

    def alternate_field_suffix
      if field.ends_with?(Spotlight::Engine.config.solr_fields.string_suffix)
        Spotlight::Engine.config.solr_fields.text_suffix
      else
        Spotlight::Engine.config.solr_fields.string_suffix
      end
    end
end
