json.data do
  json.partial! "api/v1/payment_agreements/payment_agreement", agreement: @agreement
end
