class RodadasController < ApplicationController
  before_action :set_rodada, only: [:show, :edit, :update, :destroy, :proximo, :anterior, :chama_novamente]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /rodadas
  # GET /rodadas.json
  def index
    @rodadas = Rodada.all
  end

  # GET /rodadas/1
  # GET /rodadas/1.json
  def show
  end

  # GET /rodadas/new
  def new
    @rodada = Rodada.new
  end

  # GET /rodadas/1/edit
  def edit
  end

  # POST /rodadas
  # POST /rodadas.json
  def create
    @rodada = Rodada.new(rodada_params)

    respond_to do |format|
      if @rodada.save
        format.html { redirect_to @rodada, notice: 'A Rodada foi criada com sucesso.' }
        format.json { render :show, status: :created, location: @rodada }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A rodada #{@rodada.descricao} foi criada."
        log.puts "ID DA RODADA: #{@rodada.id}, DESCRICAO: #{@rodada.descricao}, POSICAO ATUAL: #{@rodada.posicao_atual}, INSCRICAO GUEST: #{@rodada.inscricao_guest}. \n\n"
        log.close

      else
        format.html { render :new }
        format.json { render json: @rodada.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rodadas/1
  # PATCH/PUT /rodadas/1.json
  def update
    respond_to do |format|
      if @rodada.update(rodada_params)
        # notifica # TODO: reativar depois
        format.html { redirect_to @rodada, notice: 'A Rodada foi atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @rodada }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A rodada #{@rodada.descricao} foi atualizada para:"
        log.puts "ID DA RODADA: #{@rodada.id}, DESCRICAO: #{@rodada.descricao}, POSICAO ATUAL: #{@rodada.posicao_atual}, INSCRICAO GUEST: #{@rodada.inscricao_guest}. \n\n"
        log.close
      else
        format.html { render :edit }
        format.json { render json: @rodada.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rodadas/1
  # DELETE /rodadas/1.json
  def destroy
    log = File.new("LOG SISFILA.txt", "a+")
    log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A rodada #{@rodada.descricao} foi apagada."
    log.puts "ID DA RODADA: #{@rodada.id}, DESCRICAO: #{@rodada.descricao}, POSICAO ATUAL: #{@rodada.posicao_atual}, INSCRICAO GUEST: #{@rodada.inscricao_guest}. \n\n"
    log.close


    @rodada.destroy
    respond_to do |format|
      format.html { redirect_to rodadas_url, notice: 'A Rodada foi apagada com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    def notifica
      ActionCable.server.broadcast 'telao_notifications_channel', {}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rodada
      @rodada = Rodada.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rodada_params
      params.require(:rodada).permit(:descricao)
    end
end
