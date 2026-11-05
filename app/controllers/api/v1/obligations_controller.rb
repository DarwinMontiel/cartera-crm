module Api
  module V1
    class ObligationsController < BaseController
      def index
        scope = Obligation.includes(:client, :active_agreement).order(days_past_due: :desc, number: :asc)
        scope = scope.in_bucket(params[:bucket]) if params[:bucket].present?
        scope = scope.where(status: params[:status]) if params[:status].in?(Obligation.statuses.keys)
        @pagination = paginate(scope)
      end

      def show
        @obligation = Obligation.includes(:client, active_agreement: :installments).find_by!(number: params[:number])
      end
    end
  end
end
