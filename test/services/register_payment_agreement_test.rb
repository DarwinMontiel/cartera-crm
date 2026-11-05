require "test_helper"

class RegisterPaymentAgreementTest < ActiveSupport::TestCase
  setup do
    @obligation = obligations(:laura_card)
    @params = { total_amount: 2_000_000, reference: "BOT-TASK-123", installments_attributes: plan_attributes(total: 2_000_000) }
  end

  test "crea el acuerdo con sus cuotas y pasa la obligación a 'en acuerdo'" do
    result = nil
    assert_difference -> { PaymentAgreement.count } => 1, -> { Installment.count } => 2 do
      result = RegisterPaymentAgreement.call(obligation: @obligation, user: users(:agent), params: @params)
    end
    assert result.success?
    assert result.created
    assert @obligation.reload.in_agreement?
  end

  test "es idempotente por referencia" do
    first = RegisterPaymentAgreement.call(obligation: @obligation, user: users(:agent), params: @params)
    assert_no_difference -> { PaymentAgreement.count } do
      again = RegisterPaymentAgreement.call(obligation: @obligation, user: users(:agent), params: @params)
      assert again.success?
      assert_not again.created
      assert_equal first.agreement, again.agreement
    end
  end

  test "si el acuerdo es inválido no cambia el estado de la obligación" do
    result = RegisterPaymentAgreement.call(obligation: @obligation, user: users(:agent),
                                           params: @params.merge(total_amount: 10))
    assert_not result.success?
    assert @obligation.reload.delinquent?
    assert result.agreement.errors.any?
  end
end
