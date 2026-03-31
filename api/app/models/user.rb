class User < ApplicationRecord
  has_secure_password

  has_many :borrowings, dependent: :destroy

  enum :role, { member: 0, librarian: 1 }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  before_save :downcase_email

  def librarian?
    role == "librarian"
  end

  def member?
    role == "member"
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
