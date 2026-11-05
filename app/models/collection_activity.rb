class CollectionActivity < ApplicationRecord
  CONTACT_OUTCOMES = %w[contact_holder contact_third_party refused promise_to_pay].freeze

  belongs_to :obligation, touch: true
  belongs_to :user

  enum :channel, { call: "call", whatsapp: "whatsapp", visit: "visit", email: "email", sms: "sms" },
    validate: true
  enum :outcome, {
    no_answer: "no_answer",
    voicemail: "voicemail",
    wrong_number: "wrong_number",
    contact_holder: "contact_holder",
    contact_third_party: "contact_third_party",
    refused: "refused",
    promise_to_pay: "promise_to_pay"
  }, validate: true
  enum :source, { web: "web", api: "api" }, default: :web, validate: true, prefix: :from

  attribute :occurred_at, default: -> { Time.current }

  validates :occurred_at, presence: true
  validates :notes, length: { maximum: 2_000 }
  validate :not_in_the_future
  with_options if: :promise_to_pay? do
    validates :promise_date, presence: true
    validates :promise_amount, numericality: { greater_than: 0 }
    validate :promise_date_after_activity
  end

  scope :contacts, -> { where(outcome: CONTACT_OUTCOMES) }
  scope :today, -> { where(occurred_at: Time.current.all_day) }
  scope :pending_promises, -> { promise_to_pay.where(promise_date: Date.current..) }

  def contact?
    CONTACT_OUTCOMES.include?(outcome)
  end

  private
    def not_in_the_future
      errors.add(:occurred_at, :in_the_future) if occurred_at && occurred_at > 5.minutes.from_now
    end

    def promise_date_after_activity
      return if promise_date.blank? || occurred_at.blank?

      errors.add(:promise_date, :before_activity) if promise_date < occurred_at.to_date
      errors.add(:promise_date, :too_far) if promise_date > occurred_at.to_date + 30.days
    end
end
