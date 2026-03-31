class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV.fetch("JWT_SECRET_KEY", "development_secret_key")
  EXPIRATION_TIME = 24.hours

  class << self
    def encode(payload)
      payload[:exp] = EXPIRATION_TIME.from_now.to_i
      payload[:iat] = Time.current.to_i
      JWT.encode(payload, SECRET_KEY, "HS256")
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::ExpiredSignature
      raise AuthenticationError, "Token has expired"
    rescue JWT::DecodeError => e
      raise AuthenticationError, "Invalid token: #{e.message}"
    end
  end
end
