module Api
  module V1
    # Permite que integraciones (p. ej. los bots RPA del orquestador) registren gestiones.
    class CollectionActivitiesController < BaseController
      def create
        obligation = Obligation.find_by!(number: params.require(:obligation_number))
        @activity = obligation.collection_activities.build(
          activity_params.merge(user: current_user, source: :api)
        )
        if @activity.save
          render :show, status: :created
        else
          render_validation_errors(@activity)
        end
      end

      private
        def activity_params
          params.permit(:channel, :outcome, :notes, :occurred_at, :promise_date, :promise_amount)
        end
    end
  end
end
