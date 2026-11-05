json.data do
  json.id @activity.id
  json.obligation_number @activity.obligation.number
  json.extract! @activity, :channel, :outcome, :notes, :promise_amount, :source
  json.occurred_at @activity.occurred_at.iso8601
  json.promise_date @activity.promise_date&.iso8601
  json.registered_by @activity.user.name
end
