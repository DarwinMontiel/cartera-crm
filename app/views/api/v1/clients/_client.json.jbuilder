json.extract! client, :document_number, :full_name, :email, :phone, :city, :segment
json.updated_at client.updated_at.iso8601
