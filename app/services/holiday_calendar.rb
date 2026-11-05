require "net/http"

# Calendario de días hábiles de Colombia.
#
# Consume la API pública de festivos de Nager.Date (https://date.nager.at) con timeouts cortos,
# cachea el resultado por año y, si la API no responde, usa el respaldo versionado en
# config/holidays_co.yml. Un problema de red nunca debe impedir registrar un acuerdo de pago.
class HolidayCalendar
  API_URL = "https://date.nager.at/api/v3/PublicHolidays/%<year>d/CO".freeze
  CACHE_TTL = 30.days

  class FetchError < StandardError; end

  def self.default
    @default ||= new
  end

  def self.fallback_holidays
    @fallback_holidays ||= YAML.load_file(Rails.root.join("config/holidays_co.yml"), permitted_classes: [ Date ])
      .transform_keys(&:to_i)
      .transform_values { |dates| dates.map { |d| Date.iso8601(d.to_s) }.to_set }
  end

  def initialize(cache: Rails.cache, timeout: 3, logger: Rails.logger)
    @cache = cache
    @timeout = timeout
    @logger = logger
    @memo = {}
  end

  def holidays(year)
    @memo[year] ||= @cache.fetch("holiday_calendar/co/#{year}", expires_in: CACHE_TTL) { fetch(year) }
  rescue FetchError, Timeout::Error, SystemCallError, SocketError, OpenSSL::SSL::SSLError, JSON::ParserError => e
    @logger.warn("[HolidayCalendar] API no disponible para #{year} (#{e.class}: #{e.message}); se usa el respaldo")
    @memo[year] = self.class.fallback_holidays.fetch(year, Set.new)
  end

  def holiday?(date)
    holidays(date.year).include?(date)
  end

  def business_day?(date)
    !date.saturday? && !date.sunday? && !holiday?(date)
  end

  def next_business_day(date)
    date += 1 until business_day?(date)
    date
  end

  private
    def fetch(year)
      uri = URI(format(API_URL, year: year))
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                 open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.get(uri.request_uri, "Accept" => "application/json")
      end
      raise FetchError, "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).map { |holiday| Date.iso8601(holiday.fetch("date")) }.to_set
    end
end
