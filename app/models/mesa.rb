class Mesa < ApplicationRecord
  belongs_to :vaga, required: false

  def self.associa_vaga_a_mesa(vaga, id_mesa)
 
   # Aqui verifica se a vaga chamada está vazia, se estiver vazia não entra no if, evitando uma exceção, pois
   # ele chamará o proximo aluno, sendo que esse aluno não existe, ocasionando em uma exceção. 
      a = vaga
      if (a != nil)
            Vaga.where(aluno_id: vaga.aluno_id).where(posicao: vaga.posicao).update(data_chamada: Time.now) 


            # Numero de pessoas aguardando
            npag = (Vaga.where(fila_id: vaga.fila_id).last.posicao) - (vaga.posicao) 
            Fila.where(id: vaga.fila_id).update(npaguardando: npag)       
            

            # Numero de pessoas atendidas até o momento.
            npat = vaga.posicao  
            Fila.where(id: vaga.fila_id).update(npatendidas: npat)


            # Numero de pessoas total (que entraram) naquela fila
            nptt = Vaga.where(fila_id: vaga.fila_id).last.posicao
            Fila.where(id: vaga.fila_id).update(nptotal: nptt)


            # Tempo de espera na fila para cada aluno
            tnf = Time.now - vaga.created_at
            Vaga.where(id: vaga.id).update(temponafila: tnf)


            # Se a posição atual da fila for igual a 1 e não for a ultima ele "destravará" a variável que habilita a 
            # realização do calculo do tempo de atendimento. Além disso ele também setará a variavel 
            # tiatendimento (TEMPO INICIAL DO ATENDIMENTO) para o horário atual.
            if (vaga.posicao == 1) && (vaga.posicao != nptt)
              Fila.where(id: vaga.fila_id).update(realizarcalculo: true) 
              Fila.where(id: vaga.fila_id).update(tiatendimento: Time.now)
            end

            # Se a posição atual for maior que 2, se a posição atual for diferente da última e se a variavel "realizarcalculo"
            # tiver setada como true ele setará a variavel tfatendimento (TEMPO FINAL DO ATENDIMENTO) para o horário atual
            # e fará o cálculo do tempo médio de atendimento para aquela fila.
            if (vaga.posicao > 2) && (vaga.posicao != nptt) && ((Fila.where(id: vaga.fila_id).first.realizarcalculo) == true)
              Fila.where(id: vaga.fila_id).update(tfatendimento: Time.now)
              Fila.where(id: vaga.fila_id).update(tempoatendimento: ((Fila.where(id: vaga.fila_id).first.tfatendimento) - (Fila.where(id: vaga.fila_id).first.tiatendimento)) / (npat - 1))
            end        

            # Se a posição atual for a última, ele não realizará calculo algum, apenas setará a variável "realizarcalculo"
            # para false.
            if (vaga.posicao == nptt)
              Fila.where(id: vaga.fila_id).update(realizarcalculo: false)                
            end


            # Aqui calcula quantas pessoas por hora entram no sistema (lambda)
            Fila.where(id: vaga.fila_id).update(lambda: 3600 / (((Vaga.where(fila_id: vaga.fila_id).last.created_at) - (Vaga.where(fila_id: vaga.fila_id).first.created_at)) / nptt ))


            # Aqui calcula quantas pessoas por hora foram atendidas (mi)
            Fila.where(id: vaga.fila_id).update(mi: 3600 / Fila.where(id: vaga.fila_id).last.tempoatendimento)

            #AQUIIII ÉS ÉS ÉS

              @aux = 0
              @todasvagas = Vaga.where(fila_id: vaga.fila.id).where("temponafila > 0").all
                            

              for a in (1 .. Vaga.where(fila_id: vaga.fila.id).where("temponafila > 0").all.size) do      
                @aux = @aux + @todasvagas[a-1].temponafila
              end

              @aux = @aux / Vaga.where(fila_id: vaga.fila.id).where("temponafila > 0").all.size

              @tmespera = ActiveSupport::Duration.build(@aux).parts

              Fila.where(id: vaga.fila.id).update(tempomedioespera: @aux) 

       end

    mesa_atual = Mesa.find_by id: id_mesa
    if mesa_atual
      mesa_atual.update(vaga: vaga)
    end
  end

  def esta_vazia?
    self.vaga.nil?
  end

  def title
    "#{self.nome}"
  end
end
