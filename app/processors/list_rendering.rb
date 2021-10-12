# frozen_string_literal: true

# In show views we need to render fields as a list so that we can align RTL text
# to the right. This special piece of the rendering pipeline builds that list
# for us.
#
# This is registered in config/initializers/blacklight_initializer.rb.
class ListRendering < Blacklight::Rendering::AbstractStep
  include ActionView::Helpers::TextHelper

  def render
    # If it's a text area, don't make it a list.
    if config.text_area == "1" || context.try(:action_name) != "show"
      # Index page should use join step.
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
