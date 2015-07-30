require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET #login" do
    it "reponds successfully" do
      get :login
      expect(response).to have_http_status(200)
      expect(response).to be_success
    end

    it "renders the login template" do
      get :login
      expect(response).to render_template("login")
    end
  end

  describe "POST #login" do
    before :each do
      @password = "password"
      @username = "username"
      @user = create :user, username: @username, password: @password, password_confirmation: @password
    end

    context "valid username/password combination" do
      it "adds the authenticated user's id to the session" do
        post :login, session: { password: @password, username: @username }
        expect(session[:user_id]).to eq(@user.id)
      end

      it "redirects to the user's cookbooks page" do
        post :login, session: { password: @password, username: @username }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(user_cookbooks_path(@user))
      end
    end

    context "invalid username/password combination" do
      it "does not add the user's id to the session" do
        post :login, session: { password: @username, username: @password }
        expect(session[:user_id]).to eq(nil)
      end

      it "renders the login template" do
        post :login, session: { password: @username, username: @password }
        expect(response).to render_template("login")
      end
    end
  end
end
  
