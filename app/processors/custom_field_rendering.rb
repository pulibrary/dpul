# frozen_string_literal: true

# Joins values using configured value or linebreak
class CustomFieldRendering < Blacklight::Rendering::AbstractStep
  include ActionView::Helpers::TextHelper

  def render
    rendered_values = Array.wrap(values)

    if config.text_area == "1"
      begin
        parsed = JSON.parse(values)
        data = parsed["data"]
        rendered_values = data.map { |d| d["data"]["text"] }
      rescue JSON::ParserError
        # In the case that this is not a JSON data parameter, do not parse the values
        rendered_values = Array.wrap(values)
      end
    end
    options = config.separator_options || {}
    rendered = rendered_values.to_sentence(options).html_safe

    next_step(rendered)
  end
end
