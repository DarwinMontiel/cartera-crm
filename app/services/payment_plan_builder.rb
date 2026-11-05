# Genera un plan de cuotas iguales en pesos enteros: la última cuota absorbe el redondeo y las
# fechas mensuales que caen en fin de semana o festivo se corren al siguiente día hábil.
class PaymentPlanBuilder
  Installment = Data.define(:number, :due_on, :amount)

  def initialize(total:, count:, first_due_on:, calendar: PaymentAgreement.calendar)
    @total = BigDecimal(total.to_s)
    @count = Integer(count)
    @first_due_on = first_due_on.to_date
    @calendar = calendar
    raise ArgumentError, "el número de cuotas debe estar entre 1 y #{PaymentAgreement::MAX_INSTALLMENTS}" unless
      @count.between?(1, PaymentAgreement::MAX_INSTALLMENTS)
    raise ArgumentError, "el total debe ser positivo" unless @total.positive?
  end

  def call
    base = (@total / @count).floor
    (1..@count).map do |number|
      amount = number == @count ? @total - base * (@count - 1) : base
      # Se calcula desde la fecha nominal para que un corrimiento no se acumule mes a mes.
      nominal = @first_due_on.advance(months: number - 1)
      Installment.new(number:, due_on: @calendar.next_business_day(nominal), amount:)
    end
  end
end
