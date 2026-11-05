require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normaliza el correo y el nombre" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ", name: "  Ana   Ríos ")
    assert_equal "downcased@example.com", user.email_address
    assert_equal "Ana Ríos", user.name
  end

  test "exige contraseña de al menos 10 caracteres" do
    user = User.new(name: "Ana", email_address: "ana@example.com", password: "corta")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "rol por defecto es gestor e iniciales del nombre" do
    user = User.new(name: "Hernán Quintero")
    assert user.agent?
    assert_equal "HQ", user.initials
  end
end
