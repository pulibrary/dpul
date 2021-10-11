# frozen_string_literal: true

# Joins values using configured value or linebreak
class ListRendering < Blacklight::Rendering::AbstractStep
  include ActionView::Helpers::TextHelper

  def render
    # If it's a text area, don't make it a list.
    if config.text_area == "1"
      next_step(values)
    elsif context.try(:action_name) == "index"
      # Index page should use join separator.
      join_result = Blacklight::Rendering::Join.new(values, config, document, context, options, [Blacklight::Rendering::Terminator]).render
      next_step(join_result)
    else
      values.map! do |value|
        "<li dir=\"#{strip_tags(value).dir}\">#{value}</li>"
      end
      next_step("<ul>#{values.join('')}</ul>").html_safe
    end
  end
end
