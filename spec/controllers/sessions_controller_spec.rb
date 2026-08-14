# spec/controllers/sessions_controller_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
  let(:auth) do
    {
      'provider' => provider,
      'uid' => '12345',
      'info' => {
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe',
        'email' => 'john@example.com'
      }
    }
  end

  describe 'GET new' do
    context 'when not logged in' do
      it 'loads login page' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when already logged in' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to the user profile' do
        get :new
        expect(response).to redirect_to(user_profile_path)
      end

      it 'sets the already logged in notice' do
        get :new
        expect(flash[:notice]).to eq(
          'You are already logged in. Logout to switch accounts.'
        )
      end
    end
  end

  describe 'POST create' do
    before do
      request.env['omniauth.auth'] = auth
    end

    context 'with a developer provider in development environment' do
      let(:provider) { 'developer' }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        @ex_vals = {
          'provider' => 'developer',
          'uid' => '12345',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'name' => 'John Doe',
          'email' => 'john@example.com'
        }
      end

      it 'creates a developer user' do
        expect do
          post :create, params: { provider: 'developer' }
        end.to change(User, :count).by(1)
        user = User.last
        expect(user).to have_attributes(@ex_vals)
      end

      it 'stores the user id in the session' do
        post :create, params: { provider: 'developer' }
        expect(session[:user_id]).to eq(User.last.id)
      end

      it 'redirects to the root url' do
        post :create, params: { provider: 'developer' }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with a developer provider outside the development environment' do
      let(:provider) { 'developer' }

      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'renders unprocessable_entity' do
        post :create, params: { provider: 'developer' }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a user' do
        expect do
          post :create, params: { provider: 'developer' }
        end.not_to change(User, :count)
      end
    end

    context 'with the github provider' do
      let(:provider) { 'github' }

      before do
        @ex_vals = {
          'provider' => 'github',
          'uid' => '12345',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'name' => 'John Doe',
          'email' => 'john@example.com'
        }
      end

      it 'creates a GitHub user' do
        expect do
          post :create, params: { provider: 'github' }
        end.to change(User, :count).by(1)
        user = User.last
        expect(user).to have_attributes(@ex_vals)
      end
    end

    context 'when the github user already exists' do
      let(:provider) { 'github' }
      let!(:user) do
        create(
          :user,
          provider: :github,
          uid: '12345'
        )
      end

      it 'does not create another user' do
        expect do
          post :create, params: { provider: 'github' }
        end.not_to change(User, :count)
      end

      it 'uses the existing user' do
        post :create, params: { provider: 'github' }

        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'with the google_oauth2 provider' do
      let(:provider) { 'google_oauth2' }

      before do
        @ex_vals = {
          'provider' => 'google_oauth2',
          'uid' => '12345',
          'first_name' => 'John',
          'last_name' => 'Doe',
          'name' => 'John Doe',
          'email' => 'john@example.com'
        }
      end

      it 'creates a Google user' do
        expect do
          post :create, params: { provider: 'google_oauth2' }
        end.to change(User, :count).by(1)
        user = User.last
        expect(user).to have_attributes(@ex_vals)
      end

      it 'stores the user id in the session' do
        post :create, params: { provider: 'google_oauth2' }

        expect(session[:user_id]).to eq(User.last.id)
      end
    end

    context 'when the google user already exists' do
      let(:provider) { 'google_oauth2' }
      let!(:user) do
        create(
          :user,
          provider: 'google_oauth2',
          uid: '12345'
        )
      end

      it 'does not create another user' do
        expect do
          post :create, params: { provider: 'github' }
        end.not_to change(User, :count)
      end

      it 'uses the existing user' do
        post :create, params: { provider: 'github' }

        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'with a destination after login' do
      let(:provider) { 'github' }

      before do
        session[:destination_after_login] = '/some/protected/page'
      end

      it 'redirects to the destination after login' do
        post :create, params: { provider: 'github' }

        expect(response).to redirect_to('/some/protected/page')
      end
    end

    context 'with an unknown provider' do
      let(:provider) { 'unknown' }

      it 'does not create a user' do
        expect do
          post :create, params: { provider: 'unknown' }
        end.not_to change(User, :count)
      end

      it 'does not set the user session' do
        post :create, params: { provider: 'unknown' }

        expect(session[:user_id]).to be_nil
      end
    end

    context 'when already logged in' do
      let(:provider) { 'github' }
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to the user profile' do
        post :create, params: { provider: 'github' }

        expect(response).to redirect_to(user_profile_path)
      end

      it 'does not create another user' do
        expect do
          post :create, params: { provider: 'github' }
        end.not_to change(User, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'resets the session' do
      session[:user_id] = 123

      delete :destroy

      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the root path' do
      delete :destroy

      expect(response).to redirect_to(root_path)
    end

    it 'sets the logout notice' do
      delete :destroy

      expect(flash[:notice]).to eq(
        'You have successfully logged out.'
      )
    end

    context 'when already logged in' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'still allows the user to log out' do
        delete :destroy

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET omniauth_failure' do
    it 'redirects to the root url' do
      get :omniauth_failure, params: { message: 'access_denied' }

      expect(response).to redirect_to(root_url)
    end

    it 'sets the failure alert' do
      get :omniauth_failure, params: { message: 'access_denied' }

      expect(flash[:alert]).to eq(
        'Login failed unexpectedly. (access_denied)'
      )
    end
  end

  describe 'already_logged_in' do
    let(:user) { create(:user) }
    let(:provider) { 'github' }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'prevents #new from being accessed' do
      get :new

      expect(response).to redirect_to(user_profile_path)
      expect(flash[:notice]).to eq(
        'You are already logged in. Logout to switch accounts.'
      )
    end

    it 'prevents #create from being accessed' do
      request.env['omniauth.auth'] = auth

      expect do
        post :create, params: { provider: 'github' }
      end.not_to change(User, :count)

      expect(response).to redirect_to(user_profile_path)
    end
  end
end
