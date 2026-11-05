require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ]

  # Las pruebas ubican los campos como lo haría un lector de pantalla (aria-label incluido).
  Capybara.enable_aria_label = true

  def sign_in(user, password: "password-de-prueba")
    visit new_session_path
    fill_in "Correo", with: user.email_address
    fill_in "Contraseña", with: password
    click_on "Ingresar"
    assert_selector "h1", text: "Tablero"
  end
end
