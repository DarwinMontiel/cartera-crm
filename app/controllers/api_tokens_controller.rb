class ApiTokensController < ApplicationController
  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @api_token = current_user.api_tokens.build
  end

  # El token en claro solo se muestra en esta respuesta: no se guarda ni se pasa por flash.
  def create
    @api_token = current_user.api_tokens.build(params.expect(api_token: [ :name ]))
    @created = @api_token.save
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    render :index, status: @created ? :created : :unprocessable_entity
  end

  def destroy
    current_user.api_tokens.find(params[:id]).revoke!
    redirect_to api_tokens_path, notice: t("flash.api_tokens.revoked")
  end
end
