# frozen_string_literal: true

class User < ActiveRecord::Base
  include Spotlight::User

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Our CAS users have no passwords, but Invitable tries to set one, so put in a
  # dummy attribute.
  attr_accessor :password

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :omniauthable, omniauth_providers: [:cas]

  before_invitation_created :set_cas_defaults

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    username
  end

  def set_cas_defaults
    self.provider = "cas"
    self.username = default_username
    self.uid = username
  end

  def default_username
    username, domain = email.split('@')
    return username if domain == "princeton.edu"

    email
  end

  def self.from_omniauth(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid, email: "#{access_token.uid}@princeton.edu").first_or_create do |user|
      user.uid = access_token.uid
      user.provider = access_token.provider
      user.username = access_token.uid
      user.email = initialize_email(access_token.uid)
    end
  end

  def self.initialize_email(uid)
    return uid if /@/.match?(uid)

    "#{uid}@princeton.edu"
  end

  # No reason to ever send invites, because of CAS.
  def invite_pending?
    false
  end

  def add_default_roles; end
end
