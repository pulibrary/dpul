# frozen_string_literal: true

# In show views we need to render fields as a list so that we can align RTL text
# to the right. This special piece of the rendering pipeline builds that list
# for us.
#
# This is registered in config/initializers/blacklight_initializer.rb.
class ListRendering < Blacklight::Rendering::AbstractStep
  include ActionView::Helpers::TextHelper

  def render
    if use_join(config, context)
      join_result = Blacklight::Rendering::Join.new(values, config, document, context, options, [Blacklight::Rendering::Terminator]).render
      next_step(join_result)
    else
      values.map! do |value|
        "<li dir=\"#{strip_tags(value).dir}\">#{value}</li>"
      end
      next_step("<ul>#{values.join('')}</ul>").html_safe
    end
  end

  # If it's a text area or a slideshow, or a non-title index field,
  # don't make it a list.
  def use_join(config, context)
    return true if config.text_area == "1"

    # always join on search and browse pages if it's anything other than the title field
    return true if context.try(:action_name) != "show" && config.field != "full_title_tesim"

    # don't join titles on search results and browse pages
    !["catalog", "browse"].include?(context.try(:controller_name))
  end
end
