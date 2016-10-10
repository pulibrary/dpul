class RTLShowPresenter < ::Blacklight::ShowPresenter
  def field_value_separator
    "<br/>".html_safe
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
    string = "<ul>"
    super.split(field_value_separator).each do |value|
      string << "<li dir=\"#{value.dir}\">#{value}</li>"
    end
    string << "</ul>"
    string.html_safe
  end
end
