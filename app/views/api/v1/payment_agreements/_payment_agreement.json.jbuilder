json.extract! agreement, :reference, :status, :total_amount, :notes
json.obligation_number agreement.obligation.number
json.created_at agreement.created_at.iso8601
json.installments agreement.installments do |installment|
  json.extract! installment, :number, :amount
  json.due_on installment.due_on.iso8601
  json.paid_at installment.paid_at&.iso8601
end
