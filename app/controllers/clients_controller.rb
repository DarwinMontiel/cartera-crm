class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update]

  def index
    @query = params[:q].to_s.strip
    @pagination = paginate(Client.search(@query).order(:full_name))
  end

  def show
    @obligations = @client.obligations.includes(:active_agreement).order(days_past_due: :desc)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to @client, notice: t("flash.clients.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: t("flash.clients.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_client
      @client = Client.find_by!(document_number: params[:document_number])
    end

    def client_params
      params.expect(client: %i[document_number full_name email phone city segment])
    end
end
