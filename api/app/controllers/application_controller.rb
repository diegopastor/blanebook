class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from AuthenticationError, with: :unauthorized

  private

  def authenticate_user!
    @current_user = nil

    authenticate_with_http_token do |token, _options|
      payload = JwtService.decode(token)
      @current_user = User.find_by(id: payload[:user_id])
    end

    render_unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def authorize_librarian!
    render_forbidden unless current_user&.librarian?
  end

  def authorize_member!
    render_forbidden unless current_user&.member?
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def unauthorized(exception)
    render json: { error: exception.message }, status: :unauthorized
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
