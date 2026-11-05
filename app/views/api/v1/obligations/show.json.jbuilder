json.data do
  json.partial! "api/v1/obligations/obligation", obligation: @obligation
  json.client do
    json.partial! "api/v1/clients/client", client: @obligation.client
  end
  if (agreement = @obligation.active_agreement)
    json.active_agreement do
      json.partial! "api/v1/payment_agreements/payment_agreement", agreement:
    end
  end
end
