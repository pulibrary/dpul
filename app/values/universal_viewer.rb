
# frozen_string_literal: true

# Class modeling URLs for Universal Viewer installations
class UniversalViewer
  # Constructor
  # @param base_url [String] URL to the installation
  # @param uv_params [Hash] GET parameters to pass to the URL
  def initialize(base_url, **uv_params)
    @base_url = base_url
    @params = uv_params
  end

  # Generate the string representation of the URL
  # @return [String]
  def url
    components = [@base_url.to_s]

    components << "#?" unless @params.empty?

    params = []
    @params.each_pair do |name, value|
      params << "#{name}=#{CGI.escape(value)}"
    end
    components += [params.join('&')]

    components.join
  end
end
