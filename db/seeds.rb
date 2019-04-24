# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



Aluno.create(matricula: 213105001, nome:"Pablo01 SI", ativo: true, score: 7, fezPreMatricula: true, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105002, nome:"Ramon02 SI", ativo: true, score: 8, fezPreMatricula: false, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105003, nome:"Nino03 SI", ativo: true, score: 6, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105004, nome:"Moises04 SI", ativo: true, score: 5, fezPreMatricula: true, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105005, nome:"Paulinho05 SI", ativo: true, score: 4, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105006, nome:"Pablo06 SI", ativo: true, score: 7, fezPreMatricula: true, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105007, nome:"Ramon07 SI", ativo: true, score: 8, fezPreMatricula: false, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105008, nome:"Nino08 SI", ativo: true, score: 6, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105009, nome:"Moises09 SI", ativo: true, score: 5, fezPreMatricula: true, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105010, nome:"Paulinho10 SI", ativo: true, score: 4, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105011, nome:"Pablo11 SI", ativo: true, score: 7, fezPreMatricula: true, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105012, nome:"Ramon12 SI", ativo: true, score: 8, fezPreMatricula: false, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105013, nome:"Nino13 SI", ativo: true, score: 6, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105014, nome:"Moises14 SI", ativo: true, score: 5, fezPreMatricula: true, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105015, nome:"Paulinho15 SI", ativo: true, score: 4, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105016, nome:"Pablo16 SI", ativo: true, score: 7, fezPreMatricula: true, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105017, nome:"Ramon17 SI", ativo: true, score: 8, fezPreMatricula: false, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105018, nome:"Nino18 SI", ativo: true, score: 6, fezPreMatricula: false, formando: false, colegiado_id: 3)

Aluno.create(matricula: 213105019, nome:"Moises19 SI", ativo: true, score: 5, fezPreMatricula: true, formando: true, colegiado_id: 3)

Aluno.create(matricula: 213105020, nome:"Paulinho20 SI", ativo: true, score: 4, fezPreMatricula: false, formando: false, colegiado_id: 3)



### Criar colegiado
col = Colegiado.create(nome: "Bacharelado em Ciência da Computação", codigo: "112140")

### Atualizar colegiado dos alunos
Aluno.where(colegiado: nil).update(colegiado: col)

### Configurar título    
Rodada.create(descricao: "Matrícula BCC - acesse http://v.ht/filabcc")

### Criar usuário admin (troque a senha no comando abaixo):
User.create(email: "januario@example.com", superadmin_role: true, password: "jnr1111", password_confirmation: "jnr1111")
User.create(email: "rodrigo@example.com", user_role: true, password: "rdrg2222", password_confirmation: "rdrg2222")
User.create(email: "pablo@example.com", user_role: true, password: "pbl3333", password_confirmation: "pbl3333")

### Criar mesas (você pode modificá-las em `/mesas`):
Mesa.create(nome: "Sala 116, Mesa 1")
Mesa.create(nome: "Sala 116, Mesa 2")

### Criar grupos de alunos e filas: 
g = Grupo.create(nome: "Prováveis concluintes")
g.update(alunos: Aluno.where(colegiado: col).where(formando: true))
g = Grupo.create(nome: "Alunos que realizaram pré-matrícula")
g.update(alunos: Aluno.where(colegiado: col).where(fezPreMatricula: true))
g = Grupo.create(nome: "Alunos com CR >= 6,0")
g.update(alunos: Aluno.where(colegiado: col).where("score >= 60"))
g = Grupo.create(nome: "Alunos com CR entre 4,8 e 5,9")
g.update(alunos: Aluno.where(colegiado: col).where("score >= 48 AND score <= 59"))
g = Grupo.create(nome: "Alunos com CR entre 3,0 e 4,7")
g.update(alunos: Aluno.where(colegiado: col).where("score >= 30 AND score <= 47"))
g = Grupo.create(nome: "Alunos com CR <= 2,9")
g.update(alunos: Aluno.where(colegiado: col).where("score <= 29"))

### Criar filas e associar grupos iniciais:
fila1 = Fila.create(codigo: "CCA", nome: "Ciência da Computação, prioridade maior", posicao: 0, colegiado: col)
fila2 = Fila.create(codigo: "CCB", nome: "Ciência da Computação, prioridade menor", posicao: 0, colegiado: col)
g = Grupo.find_by nome: "Prováveis concluintes"
g.update(fila: fila1)
g = Grupo.find_by nome: "Alunos que realizaram pré-matrícula"
g.update(fila: fila2)

### Criar colegiado
col = Colegiado.create(nome: "Bacharelado em Sistemas de Informação", codigo: "195140")

### Atualizar colegiado dos alunos
Aluno.where(colegiado: nil).update(colegiado: col)

### Criar mesas (você pode modificá-las em `/mesas`):
Mesa.create(nome: "Sala 115")

### Criar grupos de alunos e filas:
g = Grupo.create(nome: "Alunos do BSI")
g.update(alunos: Aluno.where(colegiado: col))

### Criar filas e associar grupos iniciais:
fila = Fila.create(codigo: "BSI", nome: "Fila do BSI", posicao: 0, colegiado: col)
g.update(fila: fila)

### Criar colegiado
col = Colegiado.create(nome: "Licenciatura em Computação", codigo: "196120")

### Atualizar colegiado dos alunos
Aluno.where(colegiado: nil).update(colegiado: col)

### Criar grupos de alunos e filas:
g = Grupo.create(nome: "Alunos de LC")
g.update(alunos: Aluno.where(colegiado: col))

### Criar filas e associar grupos iniciais:
fila = Fila.create(codigo: "LC", nome: "Fila de LC", posicao: 0, colegiado: col)
g.update(fila: fila)
