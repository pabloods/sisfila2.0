class VagasController < ApplicationController
  before_action :set_vaga, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  load_and_authorize_resource

  # GET /vagas
  # GET /vagas.json
  def index
    @vagas = Vaga.order(:posicao)
    @posicao_atual = Rodada.first.posicao_atual
  end

  # GET /vagas/1
  # GET /vagas/1.json
  def show
   # @createdat = Vaga.find(params[:id]).created_at               #UTILIZANDO PARAMS
   @dif = ActiveSupport::Duration.build(Vaga.find(params[:id]).temponafila).parts

  end

  # GET /vagas/new
  def new
    @vaga = Vaga.new
  end

  # GET /vagas/1/edit
  def edit
  end

  # POST /vagas
  # POST /vagas.json
  def create
    # TODO: prevent from creating with posicao < posicao_atual
    @vaga = Vaga.new(vaga_params)

    respond_to do |format|
      if @vaga.save && @vaga.set_list_position(vaga_params[:posicao])
        format.html { redirect_to @vaga, notice: 'A Vaga foi criada com sucesso.' }
        format.json { render :show, status: :created, location: @vaga }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A vaga id #{@vaga.id} - #{@vaga.aluno.nome} foi criada."
        log.puts "ID DA VAGA #{@vaga.id}, ID DO ALUNO: #{@vaga.aluno_id}, NOME DO ALUNO: #{@vaga.aluno.nome}, POSICAO: #{@vaga.posicao}, ID DA RODADA: #{@vaga.rodada_id}, ID DA FILA: #{@vaga.fila_id}. \n\n"
        log.close

      else
        format.html { render :new }
        format.json { render json: @vaga.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vagas/1
  # PATCH/PUT /vagas/1.json
  def update
    # TODO: prevent from creating with posicao < posicao_atual
    respond_to do |format|
      if @vaga.update(vaga_params.except(:posicao)) && @vaga.set_list_position(vaga_params[:posicao])
        format.html { redirect_to @vaga, notice: 'A Vaga foi atualizada com successo.' }
        format.json { render :show, status: :ok, location: @vaga }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A vaga id #{@vaga.id} - #{@vaga.aluno.nome} foi atualizada para:"
        log.puts "ID DA VAGA #{@vaga.id}, ID DO ALUNO: #{@vaga.aluno_id}, NOME DO ALUNO: #{@vaga.aluno.nome}, POSICAO: #{@vaga.posicao}, ID DA RODADA: #{@vaga.rodada_id}, ID DA FILA: #{@vaga.fila_id}. \n\n"
        log.close

      else
        format.html { render :edit }
        format.json { render json: @vaga.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vagas/1
  # DELETE /vagas/1.json
  def destroy
        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A vaga id #{@vaga.id} - #{@vaga.aluno.nome} foi apagada."
        log.puts "ID DA VAGA #{@vaga.id}, ID DO ALUNO: #{@vaga.aluno_id}, NOME DO ALUNO: #{@vaga.aluno.nome}, POSICAO: #{@vaga.posicao}, ID DA RODADA: #{@vaga.rodada_id}, ID DA FILA: #{@vaga.fila_id}. \n\n"
        log.close

    @vaga.destroy
    respond_to do |format|
      format.html { redirect_to vagas_url, notice: 'A Vaga foi apagada com successo.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vaga
      @vaga = Vaga.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vaga_params
      params.require(:vaga).permit(:aluno_id, :rodada_id, :posicao, :data_chamada)
    end
end
