module ApplicationHelper
  BUCKET_TONES = {
    "Al día" => "ok", "1-30" => "info", "31-60" => "warn",
    "61-90" => "warn", "91-180" => "danger", ">180" => "danger"
  }.freeze

  STATUS_TONES = {
    "current" => "ok", "delinquent" => "danger", "in_agreement" => "info",
    "paid_off" => "muted", "charged_off" => "muted",
    "active" => "info", "fulfilled" => "ok", "broken" => "danger", "cancelled" => "muted"
  }.freeze

  def money(amount)
    number_to_currency(amount || 0)
  end

  def percent(ratio, precision: 1)
    return "–" if ratio.nil?

    number_to_percentage(ratio.to_f * 100, precision:, separator: ",")
  end

  # Etiqueta traducida de un enum: enum_label(Obligation, :status, "in_agreement") -> "En acuerdo"
  def enum_label(model, attribute, value)
    return "–" if value.blank?

    I18n.t("activerecord.attributes.#{model.model_name.i18n_key}.#{attribute.to_s.pluralize}.#{value}")
  end

  def enum_options(model, attribute)
    model.public_send(attribute.to_s.pluralize).keys.map { |key| [ enum_label(model, attribute, key), key ] }
  end

  def badge(text, tone = "muted")
    tag.span(text, class: "badge badge--#{tone}")
  end

  def bucket_badge(obligation)
    badge(obligation.bucket, BUCKET_TONES.fetch(obligation.bucket, "muted"))
  end

  def status_badge(record)
    badge(enum_label(record.class, :status, record.status), STATUS_TONES.fetch(record.status, "muted"))
  end

  def nav_link(label, path, icon:, active: current_page?(path))
    link_to path, class: [ "nav__link", { "nav__link--active": active } ], aria: { current: (active ? "page" : nil) } do
      safe_join([ tag.span(icon, class: "nav__icon", aria: { hidden: true }), tag.span(label) ])
    end
  end

  def page_title(title, subtitle: nil, &actions)
    content_for(:title, "#{title} · #{t('app.name')}")
    tag.header(class: "page-header") do
      safe_join([
        tag.div { safe_join([ tag.h1(title), (tag.p(subtitle, class: "page-header__subtitle") if subtitle) ].compact) },
        (tag.div(class: "page-header__actions", &actions) if actions)
      ].compact)
    end
  end
end
