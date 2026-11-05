require "test_helper"

class CollectionActivityTest < ActiveSupport::TestCase
  def build(**attributes)
    obligations(:laura_card).collection_activities.build(
      { user: users(:agent), channel: "call", outcome: "no_answer" }.merge(attributes)
    )
  end

  test "una gestión simple es válida y por defecto ocurre ahora" do
    activity = build
    assert activity.valid?
    assert_in_delta Time.current, activity.occurred_at, 2.seconds
  end

  test "una promesa exige fecha y valor positivo" do
    activity = build(outcome: "promise_to_pay")
    assert_not activity.valid?
    assert activity.errors.of_kind?(:promise_date, :blank)
    assert activity.errors.of_kind?(:promise_amount, :not_a_number)
  end

  test "la fecha de la promesa no puede ser anterior a la gestión ni superar 30 días" do
    assert build(outcome: "promise_to_pay", promise_amount: 1000, promise_date: Date.yesterday)
      .tap(&:validate).errors.of_kind?(:promise_date, :before_activity)
    assert build(outcome: "promise_to_pay", promise_amount: 1000, promise_date: 40.days.from_now.to_date)
      .tap(&:validate).errors.of_kind?(:promise_date, :too_far)
  end

  test "no acepta gestiones con fecha futura" do
    activity = build(occurred_at: 1.day.from_now)
    assert_not activity.valid?
    assert activity.errors.of_kind?(:occurred_at, :in_the_future)
  end

  test "la base de datos también exige promesas completas" do
    activity = collection_activities(:laura_promise)
    assert_raises(ActiveRecord::StatementInvalid) { activity.update_column(:promise_amount, nil) }
  end

  test "identifica contactos y promesas pendientes" do
    assert collection_activities(:laura_promise).contact?
    assert_not collection_activities(:laura_no_answer).contact?
    assert_includes CollectionActivity.pending_promises, collection_activities(:laura_promise)
    assert_equal 1, CollectionActivity.contacts.count
  end
end
