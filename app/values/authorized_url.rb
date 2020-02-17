# frozen_string_literal: true

# Represents a URL which needs to be authorized to access Figgy. If configured,
# will append an auth token to the given URL. In Production/Staging this will be
# an auth token which makes DPUL act as a "campus patron" to Figgy so it can
# index NetID only item metadata.
class AuthorizedUrl
  attr_reader :url
  def initialize(url:)
    @url = url
  end

  def to_s
    return url if auth_token.blank?
    "#{url}?auth_token=#{auth_token}"
  end

  def auth_token
    Pomegranate.config["manifest_authorization_token"]
  end
end
