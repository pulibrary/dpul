module Features
  # Provides methods for login and logout within Feature Tests
  module SessionHelpers
    # Use this in feature tests
    def sign_in(who = :user)
      user = if who.instance_of?(User)
               who.username
             else
               FactoryGirl.create(:user).username
             end
      OmniAuth.config.add_mock(:cas, uid: user)
      visit user_omniauth_authorize_path(:cas)
    end
  end
end
