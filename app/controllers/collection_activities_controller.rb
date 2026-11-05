class CollectionActivitiesController < ApplicationController
  def create
    @obligation = Obligation.find_by!(number: params[:obligation_number])
    @activity = @obligation.collection_activities.build(activity_params.merge(user: current_user, source: :web))

    if @activity.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @obligation, notice: t("flash.collection_activities.created") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "activity_form", partial: "collection_activities/form",
            locals: { obligation: @obligation, activity: @activity }
          ), status: :unprocessable_entity
        end
        format.html { redirect_to @obligation, alert: @activity.errors.full_messages.to_sentence }
      end
    end
  end

  private
    def activity_params
      params.expect(collection_activity: %i[channel outcome notes occurred_at promise_date promise_amount])
    end
end
