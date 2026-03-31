require 'rails_helper'

RSpec.describe 'Api::Auth', type: :request do
  describe 'POST /api/auth/register' do
    let(:valid_params) do
      {
        email: 'newuser@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        name: 'New User',
        role: 'member'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns token' do
        expect {
          post '/api/auth/register', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('newuser@example.com')
        expect(json['token']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for missing email' do
        post '/api/auth/register', params: valid_params.except(:email)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Email can't be blank")
      end

      it 'returns errors for invalid email format' do
        post '/api/auth/register', params: valid_params.merge(email: 'invalid')

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email is invalid')
      end

      it 'returns errors for short password' do
        post '/api/auth/register', params: valid_params.merge(password: '12345')

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Password is too short (minimum is 6 characters)')
      end

      it 'returns errors for duplicate email' do
        create(:user, email: 'newuser@example.com')
        post '/api/auth/register', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST /api/auth/login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns user and token' do
        post '/api/auth/login', params: { email: 'test@example.com', password: 'password123' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('test@example.com')
        expect(json['token']).to be_present
      end

      it 'handles case-insensitive email' do
        post '/api/auth/login', params: { email: 'TEST@EXAMPLE.COM', password: 'password123' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/api/auth/login', params: { email: 'test@example.com', password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end

      it 'returns unauthorized for non-existent email' do
        post '/api/auth/login', params: { email: 'nonexistent@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/auth/logout' do
    let(:user) { create(:user) }

    context 'when authenticated' do
      it 'returns success message' do
        delete '/api/auth/logout', headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Logged out successfully')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        delete '/api/auth/logout'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/auth/me' do
    let(:user) { create(:user, :member, name: 'Test User') }

    context 'when authenticated' do
      it 'returns current user info' do
        get '/api/auth/me', headers: auth_headers(user)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['name']).to eq('Test User')
        expect(json['user']['role']).to eq('member')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/auth/me'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
