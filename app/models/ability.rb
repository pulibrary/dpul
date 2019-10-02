# frozen_string_literal: true

# CanCan authorization evaluation model
class Ability
  include Spotlight::Ability
  def initialize(user)
    user ||= Spotlight::Engine.user_class.new

    super(user)

    # We're doing this temporarily until spotlight#1752 is solved (which may just end up doing this)
    can :create, Spotlight::FeaturedImage if user.roles.any?
  end
end
