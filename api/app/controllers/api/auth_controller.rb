module Api
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :register, :login ], raise: false
    before_action :authenticate_user!, only: [ :logout, :me ]

    def register
      user = User.new(register_params)

      if user.save
        token = JwtService.encode(user_id: user.id)
        render json: {
          user: user_response(user),
          token: token
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by(email: params[:email]&.downcase)

      if user&.authenticate(params[:password])
        token = JwtService.encode(user_id: user.id)
        render json: {
          user: user_response(user),
          token: token
        }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def logout
      render json: { message: "Logged out successfully" }, status: :ok
    end

    def me
      render json: { user: user_response(current_user) }, status: :ok
    end

    private

    def register_params
      params.permit(:email, :password, :password_confirmation, :name, :role)
    end

    def user_response(user)
      {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role
      }
    end
  end
end
