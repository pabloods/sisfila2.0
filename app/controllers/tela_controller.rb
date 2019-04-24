class TelaController < ApplicationController
  def home
    @rodada = Rodada.first
  end

  def dados
    render json: Rodada.dados
  end


  def relogio_digital
   render :text => "Agora : #{Time.current.to_s}"
  end

  def posicao_aluno
    @aluno = Aluno.find_by matricula: params[:matricula]
    @vaga = @aluno.proxima_vaga
    @posicao_aluno = @aluno.posicao_total

    if @posicao_aluno > 0
      @tempoestimado = ActiveSupport::Duration.build(@posicao_aluno * @vaga.fila.tempoatendimento).parts
      @horaestimada = Time.new + (@posicao_aluno * @vaga.fila.tempoatendimento)
      else
          @tempoestimado = ActiveSupport::Duration.build(0).parts
          @horaestimada = Time.new(1970)
      end

    log = File.new("LOG SISFILA.txt", "a+")
    log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O Aluno #{@aluno.nome} consultou sua posicao na fila"
    log.puts "ID DO ALUNO: #{@aluno.id}, MATRICULA: #{@aluno.matricula}, NOME: #{@aluno.nome}, ATIVO?: #{@aluno.ativo}, SCORE: #{@aluno.score}, FEZ PRE MATRICULA?: #{@aluno.fezPreMatricula}, FORMANDO?: #{@aluno.formando}, ID DO COLEGIADO: #{@aluno.colegiado_id}. \n\n"
    log.close 

  end
      

  # Telao
  def index
    @mesas = Mesa.where(ativo: true).where.not(aluno: nil).order(updated_at: :desc)
    @rodada = Rodada.first
    @filas = Fila.where(ativo: true).all
    render layout: 'telao'
  end

  def inscrever
    @rodada = Rodada.first

    authenticate_user! unless @rodada.inscricao_guest
    if !@rodada.inscricao_guest and !can?(:manage, :inscricao)
      return render status: 403, json: { mensagem: "Você não tem permissão." }  
    end

    matricula = params[:matricula]
    aluno = Aluno.find_by matricula: matricula
    if !aluno
      return render status: 405, json: { mensagem: "Número de matrícula não encontrado. (Cód. de Erro: 11)" }  
    end
    if !aluno.ativo
      return render status: 405, json: { mensagem: "Número de matrícula não encontrado. (Cód. de Erro: 99)" }
    end
    if !aluno.esta_em_algum_grupo
      return render status: 405, json: { mensagem: "Número de matrícula não encontrado. (Cód. de Erro: 42)" }
    end
    
    grupo = aluno.primeiro_grupo_ativo_com_fila_ativa
    if !grupo
      return render status: 405, json: { mensagem: "Matrícula não habilitada para este horário. (Cód. de Erro: 27)" }
    end

    # Checa se aluno já está em alguma fila ativa
    vaga = aluno.proxima_vaga
    if vaga
      if vaga.posicao == vaga.fila.posicao
        return render status: 405, json: { mensagem: "Já está na sua vez!" }
      else
        
        tempoestimado = ActiveSupport::Duration.build((vaga.posicao - vaga.fila.posicao) *  vaga.fila.tempoatendimento).parts 
        tempoestimadohrs = tempoestimado[:hours]
        tempoestimadomin = tempoestimado[:minutes]
        tempoestimadosec =  format("%.0f", tempoestimado[:seconds])
        

        return render status: 405, json: { mensagem: "Você já estava na fila! (posição: #{vaga.codigo}). Tempo estimado para o seu atendimento: #{tempoestimadohrs} hora(s), #{tempoestimadomin} minuto(s) e #{tempoestimadosec} segundo(s)."}
      end
    else
      # Caso contrário, adiciona à fila
      vaga = Vaga.create(aluno: aluno, fila: grupo.fila)
      InscricaoChannel.inscreve(vaga)
      render json: { aluno: vaga.aluno, posicao: "#{vaga.codigo}" }
      
      log = File.new("LOG SISFILA.txt", "a+")
      log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O Aluno #{vaga.aluno.nome} entrou na fila."
      log.puts "ID DA VAGA: #{vaga.id}, ID DO ALUNO: #{vaga.aluno_id}, POSIÇÃO: #{vaga.posicao}, RODADA: #{vaga.rodada}, ID DA FILA #{vaga.fila_id}. \n\n"
      log.close
      
    end
  end
end
