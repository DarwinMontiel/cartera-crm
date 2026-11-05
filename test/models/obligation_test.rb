require "test_helper"

class ObligationTest < ActiveSupport::TestCase
  test "clasifica la franja de mora en los límites" do
    expected = { 0 => "Al día", 1 => "1-30", 30 => "1-30", 31 => "31-60", 60 => "31-60",
                 61 => "61-90", 90 => "61-90", 91 => "91-180", 180 => "91-180", 181 => ">180", 900 => ">180" }
    expected.each do |days, bucket|
      assert_equal bucket, Obligation.new(days_past_due: days).bucket, "días #{days}"
    end
  end

  test "filtra por franja y por mora" do
    assert_equal [ obligations(:laura_card) ], Obligation.in_bucket("31-60").to_a
    assert_empty Obligation.in_bucket("inexistente")
    assert_equal 2, Obligation.past_due.count
  end

  test "calcula el mínimo para un acuerdo con la política de cobertura" do
    assert_equal BigDecimal("1470000"), obligations(:laura_card).minimum_agreement_amount
  end

  test "la base de datos impide saldos negativos aunque se salte la validación" do
    assert_raises(ActiveRecord::StatementInvalid) do
      obligations(:laura_card).update_column(:principal_balance, -1)
    end
  end

  test "expone la relación con el acuerdo vigente" do
    assert_equal payment_agreements(:andres_active), obligations(:andres_micro).active_agreement
    assert_nil obligations(:laura_card).active_agreement
  end
end
