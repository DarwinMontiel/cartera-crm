class Installment < ApplicationRecord
  belongs_to :payment_agreement, inverse_of: :installments

  validates :number, numericality: { only_integer: true, greater_than: 0 }
  validates :due_on, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :overdue, -> { where(paid_at: nil).where(due_on: ...Date.current) }
  scope :due_between, ->(range) { where(paid_at: nil, due_on: range) }

  def paid?
    paid_at.present?
  end

  def overdue?
    !paid? && due_on < Date.current
  end
end
