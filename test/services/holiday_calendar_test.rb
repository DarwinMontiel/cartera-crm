require "test_helper"

class HolidayCalendarTest < ActiveSupport::TestCase
  API = "https://date.nager.at/api/v3/PublicHolidays/2026/CO".freeze

  setup do
    @calendar = HolidayCalendar.new(cache: ActiveSupport::Cache::MemoryStore.new, logger: Logger.new(nil))
  end

  test "consulta la API de festivos y cachea el resultado por año" do
    stub = stub_request(:get, API).to_return(
      status: 200, headers: { "Content-Type" => "application/json" },
      body: [ { date: "2026-12-08", localName: "Inmaculada Concepción" }, { date: "2026-12-25", localName: "Navidad" } ].to_json
    )

    assert @calendar.holiday?(Date.new(2026, 12, 25))
    assert_not @calendar.business_day?(Date.new(2026, 12, 8))
    assert @calendar.business_day?(Date.new(2026, 12, 9))
    assert_requested stub, times: 1
  end

  test "salta fines de semana y festivos al buscar el siguiente día hábil" do
    stub_request(:get, API).to_return(status: 200, body: [ { date: "2026-12-07" } ].to_json)
    # Sábado 5 → domingo 6 → lunes 7 festivo → martes 8.
    assert_equal Date.new(2026, 12, 8), @calendar.next_business_day(Date.new(2026, 12, 5))
  end

  test "si la API falla usa el respaldo versionado" do
    stub_request(:get, API).to_return(status: 503)
    assert @calendar.holiday?(Date.new(2026, 12, 25)), "Navidad viene del respaldo"
  end

  test "si la API no responde a tiempo usa el respaldo" do
    stub_request(:get, API).to_timeout
    assert @calendar.holiday?(Date.new(2026, 1, 1))
  end

  test "el respaldo contiene 18 festivos por año" do
    assert_equal [ 18, 18 ], HolidayCalendar.fallback_holidays.values_at(2026, 2027).map(&:size)
  end
end
