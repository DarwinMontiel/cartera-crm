class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :collection_activities, dependent: :restrict_with_error
  has_many :payment_agreements, dependent: :restrict_with_error

  enum :role, { admin: "admin", agent: "agent" }, default: :agent, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.squish }

  validates :email_address, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 80 }
  validates :password, length: { minimum: 10 }, allow_nil: true

  def initials
    name.split.first(2).map { |part| part[0] }.join.upcase
  end
end
