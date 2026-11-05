module Api
  module V1
    class ClientsController < BaseController
      def index
        @pagination = paginate(Client.search(params[:q]).order(:full_name))
      end

      def show
        @client = Client.includes(obligations: :active_agreement).find_by!(document_number: params[:document_number])
      end
    end
  end
end
