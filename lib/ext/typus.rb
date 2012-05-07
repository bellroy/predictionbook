module Typus
  module Authentication
    module Basic
      include Base
      include AuthenticatedSystem

    protected

      def authenticate
        if current_user && current_user.admin
          @admin_user = FakeUser.new
          true
        else
          flash[:error] = "Sorry, you don't have access to this section"
          redirect_to root_path
          false
        end
      end
    end
  end
end

