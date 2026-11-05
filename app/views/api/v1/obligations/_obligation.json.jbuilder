json.extract! obligation, :number, :product, :principal_balance, :days_past_due, :bucket, :status
json.disbursed_on obligation.disbursed_on.iso8601
json.client_document_number obligation.client.document_number
json.active_agreement_reference obligation.active_agreement&.reference
