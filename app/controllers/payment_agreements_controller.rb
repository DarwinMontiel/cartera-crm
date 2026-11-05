class PaymentAgreementsController < ApplicationController
  before_action :set_obligation, only: %i[new create plan]

  def index
    @status = params[:status].presence_in(PaymentAgreement.statuses.keys) || "active"
    scope = PaymentAgreement.where(status: @status).includes(:installments, obligation: :client)
    @pagination = paginate(scope.order(created_at: :desc))
  end

  def show
    @agreement = PaymentAgreement.includes(:installments, :user, obligation: :client)
      .find_by!(reference: params[:reference])
  end

  def new
    @agreement = @obligation.payment_agreements.build(total_amount: @obligation.minimum_agreement_amount.ceil)
    build_plan(@agreement, count: 3, first_due_on: next_month_due_date)
  end

  def create
    result = RegisterPaymentAgreement.call(obligation: @obligation, user: current_user, params: agreement_params)
    @agreement = result.agreement
    if result.success?
      redirect_to payment_agreement_path(@agreement), notice: t("flash.payment_agreements.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Genera el plan de cuotas en el servidor (días hábiles con el calendario de festivos)
  # y reemplaza la tabla de cuotas del formulario con un Turbo Stream.
  def plan
    total = params.dig(:payment_agreement, :total_amount).to_s.split(".").first.to_s.gsub(/\D/, "").to_d
    total = @obligation.minimum_agreement_amount.ceil unless total.positive?
    @agreement = @obligation.payment_agreements.build(total_amount: total)
    count = params[:plan_count].to_i.clamp(1, PaymentAgreement::MAX_INSTALLMENTS)
    first_due_on = [ parse_date(params[:plan_first_due_on]) || next_month_due_date, Date.current ].max
    build_plan(@agreement, count:, first_due_on:)
  end

  private
    def set_obligation
      @obligation = Obligation.find_by!(number: params[:obligation_number])
    end

    def parse_date(value)
      Date.iso8601(value.to_s)
    rescue Date::Error
      nil
    end

    def next_month_due_date
      Date.current.next_month.change(day: [ Date.current.day, 28 ].min)
    end

    def build_plan(agreement, count:, first_due_on:, total: agreement.total_amount)
      PaymentPlanBuilder.new(total:, count:, first_due_on:).call.each do |row|
        agreement.installments.build(number: row.number, due_on: row.due_on, amount: row.amount)
      end
    end

    def agreement_params
      params.expect(payment_agreement: [
        :total_amount, :notes, :reference,
        installments_attributes: [ [ :id, :number, :due_on, :amount, :_destroy ] ]
      ])
    end
end
