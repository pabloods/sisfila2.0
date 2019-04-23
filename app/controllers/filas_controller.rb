class FilasController < ApplicationController
  require 'vagas_controller'
  require "time"
  before_action :set_fila, only: [:show, :edit, :update, :destroy, :anterior, :proximo]
  load_and_authorize_resource

  # GET /filas
  # GET /filas.json
  def index
    @filas = Fila.all
  end

  # GET /filas/1
  # GET /filas/1.json
  def show
    @vaga = @fila.vaga_atual
    @mesa_atual = Mesa.find_by id: session[:mesa]

    @tmpatd = ActiveSupport::Duration.build(Fila.find(params[:id]).tempoatendimento).parts
  end

  # GET /filas/new
  def new
    @fila = Fila.new
  end

  # GET /filas/1/edit
  def edit
  end

  # POST /filas
  # POST /filas.json
  def create
    @fila = Fila.new(fila_params)

    respond_to do |format|
      if @fila.save
        if (@fila.vagas.find_by(posicao: @fila.posicao))
          Mesa.associa_vaga_a_mesa(@fila.vaga, session[:mesa])
          notifica
        end
        format.html { redirect_to @fila, notice: 'A Fila foi criada com successo.' }
        format.json { render :show, status: :created, location: @fila }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A fila #{@fila.nome} foi criada."
        log.puts "ID DA FILA: #{@fila.id}, CODIGO: #{@fila.codigo}, PRIORIDADE: #{@fila.prioridade}, ATIVO?: #{@fila.ativo},  NOME: #{@fila.nome},  POSICAO: #{@fila.posicao}, ID DO COLEGIADO: #{@fila.colegiado_id}. \n\n"
        log.close

      else
        format.html { render :new }
        format.json { render json: @fila.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /filas/1
  # PATCH/PUT /filas/1.json
  def update
    respond_to do |format|
      if @fila.update(fila_params)
        format.html { redirect_to @fila, notice: 'A Fila foi atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @fila }

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A fila #{@fila.nome} foi atualizada para:"
        log.puts "ID DA FILA: #{@fila.id}, CODIGO: #{@fila.codigo}, PRIORIDADE: #{@fila.prioridade}, ATIVO?: #{@fila.ativo},  NOME: #{@fila.nome},  POSICAO: #{@fila.posicao}, ID DO COLEGIADO: #{@fila.colegiado_id}. \n\n"
        log.close

      else
        format.html { render :edit }
        format.json { render json: @fila.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /filas/1
  # DELETE /filas/1.json
  def destroy
    log = File.new("LOG SISFILA.txt", "a+")
    log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - A fila #{@fila.nome} foi apagada."
    log.puts "ID DA FILA: #{@fila.id}, CODIGO: #{@fila.codigo}, PRIORIDADE: #{@fila.prioridade}, ATIVO?: #{@fila.ativo},  NOME: #{@fila.nome},  POSICAO: #{@fila.posicao}, ID DO COLEGIADO: #{@fila.colegiado_id}. \n\n"
    log.close


    @fila.destroy
    respond_to do |format|
      format.html { redirect_to filas_url, notice: 'A Fila foi apagada com sucesso.' }
      format.json { head :no_content }
    end
  end

  def anterior
    @fila.chama_proximo(session[:mesa], -1)
    notifica
    redirect_to @fila
  end

  def proximo
    if @fila.posicao == @fila.vagas.count
      Mesa.associa_vaga_a_mesa(nil, session[:mesa])
    else
      @fila.chama_proximo(session[:mesa], 1)
    end
    notifica
    redirect_to @fila
  end

  def gera_estatisticas_tela

    if (@fila.posicao <= 2) || (@fila.npatendidas <= 2) 
      redirect_to @fila
      else

        # TEORIA DAS FILAS - Tempo médio de espera na fila      
        @tme = 3600 * ((@fila.lambda) / (@fila.mi * (@fila.mi - @fila.lambda)))
        if (@tme > 0)
        @tmespera =  ActiveSupport::Duration.build(@tme).parts
          else
            @tmespera =  ActiveSupport::Duration.build(0).parts
        end


        # Tempo médio de atendimento
        @tmpatdfila = ActiveSupport::Duration.build(Fila.find(params[:id]).tempoatendimento).parts


        # TEORIA DAS FILAS - Número médio de clientes na fila
        @nmcf = (@fila.lambda * @fila.lambda) / (@fila.mi * (@fila.mi - @fila.lambda))
        if @nmcf > 0
          @nmcf
            else
            @nmcf = "Não calculado"
        end


        # Horário em que a primeira pessoa entrou na fila
        @prifila = Vaga.where(fila_id: @fila.id).first.created_at
        if @prifila.nil?
          @prifila = Time.new(1970)
        end


        # Horário em que a última pessoa entrou na fila
        @ultfila = Vaga.where(fila_id: @fila.id).last.created_at
        if @ultfila.nil?
          @ultfila = Time.new(1970)
        end


        # Horário em que a primeira pessoa foi atendida
        @priatendida = Vaga.where(fila_id: @fila.id).first.data_chamada
        if @priatendida.nil?
          @priatendida = Time.new(1970)
        end


        # Horário em que a ultima pessoa foi atendida
        @comp = Vaga.where(fila_id: @fila.id).all
        @ultatendida = @comp[@fila.npatendidas - 1].data_chamada
        if (@ultatendida.nil?) || (@fila.npatendidas <= 0)
          @ultatendida = Time.new(1970)
        end


        # TEORIA DAS FILAS - Intensidade da fila
        @intensidadefila = (@fila.lambda / @fila.mi)

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O usuário pediu para gerar as estatisticas em tela na fila #{@fila.nome}."
        log.puts "ID DA FILA: #{@fila.id}, CODIGO: #{@fila.codigo}, PRIORIDADE: #{@fila.prioridade}, ATIVO?: #{@fila.ativo},  NOME: #{@fila.nome},  POSICAO: #{@fila.posicao}, ID DO COLEGIADO: #{@fila.colegiado_id}. \n\n"
        log.close

    end


  end


def gera_estatisticas_arquivo


   if (@fila.posicao <= 2) || (@fila.npatendidas <= 2)   #FALTA MELHORAR ESSA CONDIÇÃO
      redirect_to @fila
      else

        arq = File.new("#{@fila.id} #{@fila.nome} #{Time.new.year}-#{Time.new.month}-#{Time.new.day}, #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec}.txt", "w")

        arq.puts "Estatística gerada às: #{Time.new.day}-#{Time.new.month}-#{Time.new.year}, #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} \n \n \n \n"

        
        # Número de pessoas aguardando
        arq.puts "Número de pessoas aguardando: #{@fila.npaguardando} \n \n"


        # Número de pessoas atendidas
        arq.puts "Número de pessoas atendidas: #{@fila.npatendidas} \n \n"


        # Número de pessoas que entraram na fila
        arq.puts "Número de pessoas que entraram na fila: #{@fila.nptotal} \n \n"


        # TEORIA DAS FILAS - Tempo médio de espera na fila
        tme = 3600 * ((@fila.lambda) / (@fila.mi * (@fila.mi - @fila.lambda)))
        if (tme > 0)
        tmespera =  ActiveSupport::Duration.build(tme).parts
          else
            tmespera =  ActiveSupport::Duration.build(0).parts
        end
        arq.puts "Tempo médio de espera na fila: #{tmespera[:hours]} hora(s), #{tmespera[:minutes]} minuto(s) e #{format("%.0f", tmespera[:seconds])} segundo(s) \n \n"


        # Tempo médio de atendimento
        tmpatdfila = ActiveSupport::Duration.build(Fila.find(params[:id]).tempoatendimento).parts
        arq.puts "Tempo médio de atendimento: #{tmpatdfila[:hours]} hora(s), #{tmpatdfila[:minutes]} minuto(s) e #{format("%.0f", tmpatdfila[:seconds])} segundo(s) \n \n"


        # TEORIA DAS FILAS - Número médio de clientes na fila
        nmcf = (@fila.lambda * @fila.lambda) / (@fila.mi * (@fila.mi - @fila.lambda))
        if nmcf > 0
          nmcf
            else
            nmcf = "Não calculado"
        end
        arq.puts "Número médio de clientes na fila: #{nmcf} \n \n"


        # Horário em que a a primeira pessoa entrou na fila
        prifila = Vaga.where(fila_id: @fila.id).first.created_at
        if prifila.nil?
          prifila = Time.new(1970)
        end
        arq.puts "Horário em que a primeira pessoa entrou na fila: #{prifila.day}-#{prifila.month}-#{prifila.year}, #{prifila.hour}:#{prifila.min}:#{prifila.sec} \n \n"


        # Horário em que a última pessoa entrou na fila
        ultfila = Vaga.where(fila_id: @fila.id).last.created_at
        if ultfila.nil?
          ultfila = Time.new(1970)
        end
        arq.puts "Horário em que a ultima pessoa entrou na fila: #{ultfila.day}-#{ultfila.month}-#{ultfila.year}, #{ultfila.hour}:#{ultfila.min}:#{ultfila.sec} \n \n"

        
        # Horário em que a primeira pessoa foi atendida
        priatendida = Vaga.where(fila_id: @fila.id).first.data_chamada
        if priatendida.nil?
          priatendida = Time.new(1970)
        end
        arq.puts "Horário em que a primeira pessoa foi atendida: #{priatendida.day}-#{priatendida.month}-#{priatendida.year}, #{priatendida.hour}:#{priatendida.min}:#{priatendida.sec} \n \n"


        # Horário em que a ultima pessoa foi atendida
        comp = Vaga.where(fila_id: @fila.id).all
        ultatendida = comp[@fila.npatendidas - 1].data_chamada
        if (ultatendida.nil?) || (@fila.npatendidas <= 0)
          ultatendida = Time.new(1970)
        end
        arq.puts "Horário em que a ultima pessoa foi atendida: #{ultatendida.day}-#{ultatendida.month}-#{ultatendida.year}, #{ultatendida.hour}:#{ultatendida.min}:#{ultatendida.sec} \n \n"


        # TEORIA DAS FILAS - Intensidade da fila
        intensidadefila = (@fila.lambda / @fila.mi)
        arq.puts "Intensidade da fila: #{intensidadefila} \n \n"


        arq.close

        log = File.new("LOG SISFILA.txt", "a+")
        log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O usuário pediu para salvar em arquivo as estatisticas da fila #{@fila.nome}."
        log.puts "ID DA FILA: #{@fila.id}, CODIGO: #{@fila.codigo}, PRIORIDADE: #{@fila.prioridade}, ATIVO?: #{@fila.ativo},  NOME: #{@fila.nome},  POSICAO: #{@fila.posicao}, ID DO COLEGIADO: #{@fila.colegiado_id}. \n\n"
        log.close
    end

end



  def esvazia_mesa
    Mesa.associa_vaga_a_mesa(nil, session[:mesa])
    notifica
    redirect_to @fila
  end

  private

    def notifica
      ActionCable.server.broadcast 'telao_notifications_channel', Rodada.dados
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_fila
      @fila = Fila.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fila_params
      params.require(:fila).permit(:codigo, :nome, :prioridade, :ativo, :posicao)
    end
end
