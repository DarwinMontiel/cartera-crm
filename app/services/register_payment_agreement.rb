# Caso de uso: registrar un acuerdo de pago sobre una obligación.
#
# - Transaccional: el acuerdo, sus cuotas y el cambio de estado de la obligación se guardan
#   juntos o no se guarda nada.
# - Idempotente por referencia: si un integrador (p. ej. un bot RPA) reintenta con la misma
#   referencia, se devuelve el acuerdo existente en lugar de crear uno duplicado.
class RegisterPaymentAgreement
  Result = Data.define(:agreement, :created) do
    def success? = agreement.persisted? && agreement.errors.empty?
  end

  def self.call(...) = new(...).call

  def initialize(obligation:, user:, params:)
    @obligation = obligation
    @user = user
    @params = params
  end

  def call
    existing = reference.present? && @obligation.payment_agreements.find_by(reference:)
    return Result.new(agreement: existing, created: false) if existing

    agreement = @obligation.payment_agreements.build(@params.merge(user: @user))
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless agreement.save

      @obligation.update!(status: :in_agreement)
    end
    Result.new(agreement:, created: agreement.persisted?)
  rescue ActiveRecord::RecordNotUnique
    # Carrera entre dos solicitudes simultáneas: el índice parcial de la base gana.
    agreement.errors.add(:obligation, :already_has_active_agreement)
    Result.new(agreement:, created: false)
  end

  private
    def reference
      @params[:reference].presence || @params["reference"].presence
    end
end
