json.data do
  json.partial! "api/v1/clients/client", client: @client
  json.obligations @client.obligations, partial: "api/v1/obligations/obligation", as: :obligation
end
