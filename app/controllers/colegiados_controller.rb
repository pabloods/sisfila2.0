class ColegiadosController < ApplicationController
  before_action :set_colegiado, only: [:show, :edit, :update, :destroy, :proximo, :anterior, :esvazia_mesa]
  load_and_authorize_resource
  require 'time'
  require 'vagas_controller'
  
  # GET /colegiados
  # GET /colegiados.json
  def index
    @colegiados = Colegiado.all
  end

  # GET /colegiados/1
  # GET /colegiados/1.json
  def show
    # @vaga = @fila.vaga_atual
    @mesa_atual = Mesa.find_by id: session[:mesa]
    @vaga = @mesa_atual.vaga if @mesa_atual
  end

  # GET /colegiados/new
  def new
    @colegiado = Colegiado.new
  end

  # GET /colegiados/1/edit
  def edit
  end

  # POST /colegiados
  # POST /colegiados.json
  def create
    @colegiado = Colegiado.new(colegiado_params)

    respond_to do |format|
      if @colegiado.save
        format.html { redirect_to @colegiado, notice: 'O Colegiado foi criado com sucesso.' }
        format.json { render :show, status: :created, location: @colegiado }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O colegiado #{@colegiado.nome} foi criado."
        log.puts "ID DO COLEGIADO: #{@colegiado.id}, NOME: #{@colegiado.nome}, CODIGO: #{@colegiado.codigo}, SIGLA: #{@colegiado.sigla}. \n\n"
        log.close

      else
        format.html { render :new }
        format.json { render json: @colegiado.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /colegiados/1
  # PATCH/PUT /colegiados/1.json
  def update
    respond_to do |format|
      if @colegiado.update(colegiado_params)
        format.html { redirect_to @colegiado, notice: 'O Colegiado foi atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @colegiado }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O colegiado #{@colegiado.nome} foi atualizado para:"
        log.puts "ID DO COLEGIADO: #{@colegiado.id}, NOME: #{@colegiado.nome}, CODIGO: #{@colegiado.codigo}, SIGLA: #{@colegiado.sigla}. \n\n"
        log.close
      else
        format.html { render :edit }
        format.json { render json: @colegiado.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /colegiados/1
  # DELETE /colegiados/1.json
  def destroy
    log = File.new("LOG SISFILA.txt", "a+")
    log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O colegiado #{@colegiado.nome} foi apagado."
    log.puts "ID DO COLEGIADO: #{@colegiado.id}, NOME: #{@colegiado.nome}, CODIGO: #{@colegiado.codigo}, SIGLA: #{@colegiado.sigla}. \n\n"
    log.close

    @colegiado.destroy
    respond_to do |format|
      format.html { redirect_to colegiados_url, notice: 'O Colegiado foi apagado com sucesso.' }
      format.json { head :no_content }
    end
  end

  def anterior
    raise Exception, "Not implemented"
  end

  def proximo

    # Na linha abaixo é onde seta a hora da chamada na variavel data_chamada
    # Vaga.find(params[:aluno_id]).update(data_chamada: Time.now)
    # Vaga.first.update(data_chamada: Time.now)
    
    #ISSO FUNCIONA 
    #@rs = Vaga.first
    #Vaga.where(aluno_id: @rs.aluno_id).update(data_chamada: Time.now)

    if !session[:mesa]
      return redirect_to @colegiado, notice: 'É preciso selecionar uma mesa antes.'
    end
    mesa_atual = Mesa.find_by id: session[:mesa]
    if !mesa_atual
      return redirect_to @colegiado, notice: 'É preciso selecionar uma mesa antes.'
    end
    @fila = @colegiado.proxima_fila_nao_vazia
    if @fila
      if @fila.posicao == @fila.vagas.count && session[:mesa]
        if not mesa_atual.esta_vazia?
          Mesa.associa_vaga_a_mesa(nil, session[:mesa]) 
          notifica
        end
      else
        @fila.chama_proximo(session[:mesa], 1)
        notifica
      end
    else
      if not mesa_atual.esta_vazia?
        Mesa.associa_vaga_a_mesa(nil, session[:mesa])
        notifica
      end
    end
    redirect_to @colegiado
  end



  def esvazia_mesa
    Mesa.associa_vaga_a_mesa(nil, session[:mesa])
    notifica
    redirect_to @colegiado
  end

  private

    def notifica
      ActionCable.server.broadcast 'telao_notifications_channel', Rodada.dados
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_colegiado
      @colegiado = Colegiado.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def colegiado_params
      params.require(:colegiado).permit(:nome, :codigo)
    end


end
