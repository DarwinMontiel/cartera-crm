class DashboardController < ApplicationController
  def show
    @summary = PortfolioSummary.call
    @balance_by_bucket = PortfolioSummary.balance_by_bucket
    @recent_activities = CollectionActivity.includes(:user, obligation: :client)
      .order(occurred_at: :desc).limit(8)
    @upcoming_installments = Installment.due_between(Date.current..14.days.from_now.to_date)
      .includes(payment_agreement: { obligation: :client }).order(:due_on).limit(8)
  end
end
