module Api
  module V1
    # Registro idempotente de acuerdos: reintentar con la misma "reference" devuelve el acuerdo
    # existente (200) en lugar de crear un duplicado (201 la primera vez).
    class PaymentAgreementsController < BaseController
      def show
        @agreement = PaymentAgreement.includes(:installments, :obligation).find_by!(reference: params[:reference])
      end

      def create
        obligation = Obligation.find_by!(number: params.require(:obligation_number))
        result = RegisterPaymentAgreement.call(obligation:, user: current_user, params: agreement_params)
        @agreement = result.agreement

        if result.success?
          render :show, status: result.created ? :created : :ok
        else
          render_validation_errors(@agreement)
        end
      end

      private
        def agreement_params
          permitted = params.permit(:reference, :total_amount, :notes, installments: %i[number due_on amount])
          permitted.merge(installments_attributes: permitted.delete(:installments) || [])
        end
    end
  end
end
