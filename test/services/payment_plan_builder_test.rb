require "test_helper"

class PaymentPlanBuilderTest < ActiveSupport::TestCase
  test "divide en cuotas iguales de pesos enteros y la última absorbe el redondeo" do
    plan = PaymentPlanBuilder.new(total: 1_000_000, count: 3, first_due_on: Date.new(2027, 2, 10),
                                  calendar: FakeCalendar.new([])).call
    assert_equal [ 333_333, 333_333, 333_334 ], plan.map(&:amount)
    assert_equal 1_000_000, plan.sum(&:amount)
    assert_equal [ 1, 2, 3 ], plan.map(&:number)
  end

  test "mueve al siguiente día hábil sin acumular el corrimiento" do
    # 2027-03-22 es festivo (San José, lunes) y 2027-05-22 cae sábado.
    calendar = FakeCalendar.new([ Date.new(2027, 3, 22) ])
    plan = PaymentPlanBuilder.new(total: 300_000, count: 3, first_due_on: Date.new(2027, 3, 22), calendar:).call
    assert_equal [ Date.new(2027, 3, 23), Date.new(2027, 4, 22), Date.new(2027, 5, 24) ], plan.map(&:due_on)
  end

  test "respeta los fines de mes" do
    plan = PaymentPlanBuilder.new(total: 200_000, count: 2, first_due_on: Date.new(2027, 1, 29),
                                  calendar: FakeCalendar.new([])).call
    assert_equal Date.new(2027, 3, 1), plan.last.due_on, "28-feb-2027 es domingo"
  end

  test "valida los argumentos" do
    assert_raises(ArgumentError) { PaymentPlanBuilder.new(total: 100, count: 0, first_due_on: Date.current) }
    assert_raises(ArgumentError) { PaymentPlanBuilder.new(total: 100, count: 37, first_due_on: Date.current) }
    assert_raises(ArgumentError) { PaymentPlanBuilder.new(total: 0, count: 2, first_due_on: Date.current) }
  end
end
