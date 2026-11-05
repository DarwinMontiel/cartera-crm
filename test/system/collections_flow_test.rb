require "application_system_test_case"

# Flujos con JavaScript (Stimulus + Turbo) en un navegador real.
class CollectionsFlowTest < ApplicationSystemTestCase
  setup { sign_in users(:agent) }

  test "registrar una promesa de pago muestra los campos dinámicos y actualiza el historial sin recargar" do
    visit obligation_path(obligations(:laura_card))

    assert_no_field "Fecha de la promesa"
    select "Llamada", from: "Canal"
    select "Promesa de pago", from: "Resultado"
    assert_field "Fecha de la promesa"
    fill_in "Fecha de la promesa", with: 2.days.from_now.to_date
    fill_in "Valor prometido", with: "450000"
    fill_in "Observaciones", with: "Pagará con la prima"
    click_on "Registrar gestión"

    within "#activities" do
      assert_text "Promesa de pago"
      assert_text "Pagará con la prima"
    end
    assert_text "Gestión registrada."
    assert_no_field "Fecha de la promesa" # el formulario se reinicia
  end

  test "acuerdo de pago: generar plan, agregar cuota, cuadrar total y registrar" do
    visit new_obligation_payment_agreement_path(obligations(:laura_card))

    fill_in "Valor total", with: "2000000"
    fill_in "Número de cuotas", with: "4"
    fill_in "Primer vencimiento", with: Date.current + 12
    click_on "Generar plan"
    assert_selector "tbody tr.installment-row", count: 4
    assert_text "cuadra con el total"

    click_on "+ Agregar cuota"
    assert_selector "tbody tr.installment-row", count: 5
    within all("tbody tr.installment-row").last do
      assert_field "Fecha de vencimiento", with: /\A\d{4}-\d{2}-\d{2}\z/ # propone el mes siguiente
      fill_in "Valor de la cuota", with: "100000"
    end
    assert_text "sobran $ 100.000"

    within all("tbody tr.installment-row").last do
      click_on "Eliminar cuota"
    end
    assert_selector "tbody tr.installment-row", count: 4
    assert_text "cuadra con el total"

    click_on "Registrar acuerdo"
    assert_text "Acuerdo de pago registrado."
    assert_selector "h1", text: /Acuerdo AC-/
    assert_selector "tbody tr", count: 4
  end

  test "la búsqueda de clientes filtra mientras se escribe" do
    visit clients_path
    fill_in "Buscar cliente", with: "pérez"
    within "turbo-frame#clients" do
      assert_text "Andrés Pérez Duarte"
      assert_no_text "Laura Gómez Ríos"
    end
  end
end
