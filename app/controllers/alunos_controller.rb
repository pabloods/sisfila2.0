class AlunosController < ApplicationController
  before_action :set_aluno, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  # GET /alunos
  # GET /alunos.json
  def index
    @alunos = Aluno.all
  end

  # GET /alunos/1
  # GET /alunos/1.json
  def show
  	#@createdat = Aluno.find(params[:id]).created_at


  end

  # GET /alunos/new
  def new
    @aluno = Aluno.new

  end

  # GET /alunos/1/edit
  def edit
  end

  # POST /alunos
  # POST /alunos.json
  def create
    @aluno = Aluno.new(aluno_params)

    respond_to do |format|
      if @aluno.save
        format.html { redirect_to @aluno, notice: 'O Aluno foi criado com sucesso.' }
        format.json { render :show, status: :created, location: @aluno }

      log = File.new("LOG SISFILA.txt", "a+")
      log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O Aluno #{@aluno.nome} foi criado."
      log.puts "ID DO ALUNO: #{@aluno.id}, MATRICULA: #{@aluno.matricula}, NOME: #{@aluno.nome}, ATIVO?: #{@aluno.ativo}, SCORE: #{@aluno.score}, FEZ PRE MATRICULA?: #{@aluno.fezPreMatricula}, FORMANDO?: #{@aluno.formando}, ID DO COLEGIADO: #{@aluno.colegiado_id}. \n\n"
      log.close
      else
        format.html { render :new }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alunos/1
  # PATCH/PUT /alunos/1.json
  def update
    respond_to do |format|
      if @aluno.update(aluno_params)
        format.html { redirect_to @aluno, notice: 'O Aluno foi atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @aluno }

      log = File.new("LOG SISFILA.txt", "a+")
      log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O Aluno #{@aluno.nome} foi atualizado para:"
      log.puts "ID DO ALUNO: #{@aluno.id}, MATRICULA: #{@aluno.matricula}, NOME: #{@aluno.nome}, ATIVO?: #{@aluno.ativo}, SCORE: #{@aluno.score}, FEZ PRE MATRICULA?: #{@aluno.fezPreMatricula}, FORMANDO?: #{@aluno.formando}, ID DO COLEGIADO: #{@aluno.colegiado_id}. \n\n"
      log.close
      else
        format.html { render :edit }
        format.json { render json: @aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alunos/1
  # DELETE /alunos/1.json
  def destroy
      log = File.new("LOG SISFILA.txt", "a+")
      log.puts "#{Time.new.day}/#{Time.new.month}/#{Time.new.year} #{Time.new.hour}:#{Time.new.min}:#{Time.new.sec} - O Aluno #{@aluno.nome} foi apagado."
      log.puts "ID DO ALUNO: #{@aluno.id}, MATRICULA: #{@aluno.matricula}, NOME: #{@aluno.nome}, ATIVO?: #{@aluno.ativo}, SCORE: #{@aluno.score}, FEZ PRE MATRICULA?: #{@aluno.fezPreMatricula}, FORMANDO?: #{@aluno.formando}, ID DO COLEGIADO: #{@aluno.colegiado_id}. \n\n"
      log.close

    @aluno.destroy
    respond_to do |format|
      format.html { redirect_to alunos_url, notice: 'O Aluno foi apagado com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aluno
      @aluno = Aluno.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def aluno_params
      params.require(:aluno).permit(:matricula, :nome, :ativo, :score, :fezPreMatricula, :formando)
    end
end
