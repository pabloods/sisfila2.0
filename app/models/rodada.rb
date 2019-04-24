class Rodada < ApplicationRecord
  has_many :vagas, -> { order(posicao: :asc) }

  # TODO: remover
  def proximos(n)
    Vaga.where("posicao > ?", self.posicao_atual).order(posicao: :asc).limit(n)
  end

  # TODO: remover
  # Retorna a primeira posição do aluno na fila a partir da posicao_atual.
  # Se o aluno não estiver na fila a partir da posicao_atual, retorna nil
  def posicao_aluno(aluno)
    vagas = Vaga.where("posicao >= ?", self.posicao_atual).where(aluno: aluno).order(posicao: :asc).limit(1)
    vagas && vagas.size >= 1 ? vagas[0].posicao - self.posicao_atual : nil
  end

  def self.dados
    mesas = Mesa.eager_load({vaga: [:aluno, :fila]})\
      .where(ativo: true)\
      .where.not(vaga: nil)\
      .order(updated_at: :desc)\
      .as_json(include: {vaga: {include: [:aluno, :fila]}})

    rodada = Rodada.first.as_json

    return { mesas: mesas, rodada: rodada }
  end

end
