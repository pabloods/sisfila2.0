# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_28_012148) do

  create_table "alunos", force: :cascade do |t|
    t.string "matricula"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo", default: true
    t.integer "score"
    t.boolean "fezPreMatricula", default: false
    t.boolean "formando", default: false
    t.integer "colegiado_id"
    t.index ["colegiado_id"], name: "index_alunos_on_colegiado_id"
    t.index ["matricula"], name: "index_alunos_on_matricula", unique: true
  end

  create_table "alunos_grupos", id: false, force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.integer "grupo_id", null: false
    t.index ["aluno_id", "grupo_id"], name: "index_alunos_grupos_on_aluno_id_and_grupo_id"
  end

  create_table "colegiados", force: :cascade do |t|
    t.string "nome"
    t.string "codigo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sigla"
  end

  create_table "filas", force: :cascade do |t|
    t.string "codigo"
    t.integer "prioridade"
    t.boolean "ativo", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nome"
    t.integer "posicao", default: 1, null: false
    t.integer "colegiado_id"
    t.integer "npaguardando"
    t.integer "npatendidas"
    t.integer "nptotal"
    t.datetime "tiatendimento"
    t.datetime "tfatendimento"
    t.boolean "realizarcalculo", default: true
    t.float "tempoatendimento"
    t.float "mi", default: 0.0
    t.float "lambda", default: 0.0
    t.float "tempomedioespera"
    t.index ["colegiado_id"], name: "index_filas_on_colegiado_id"
  end

  create_table "grupos", force: :cascade do |t|
    t.string "nome"
    t.integer "prioridade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo", default: true
    t.integer "fila_id"
    t.index ["fila_id"], name: "index_grupos_on_fila_id"
  end

  create_table "mesas", force: :cascade do |t|
    t.string "nome"
    t.boolean "ativo", default: true
    t.integer "aluno_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vaga_id"
    t.index ["aluno_id"], name: "index_mesas_on_aluno_id"
    t.index ["vaga_id"], name: "index_mesas_on_vaga_id"
  end

  create_table "rodadas", force: :cascade do |t|
    t.string "descricao"
    t.integer "posicao_atual"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "inscricao_guest"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superadmin_role", default: false
    t.boolean "supervisor_role", default: false
    t.boolean "user_role", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vagas", force: :cascade do |t|
    t.integer "aluno_id"
    t.integer "posicao"
    t.datetime "data_chamada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rodada_id"
    t.integer "fila_id"
    t.integer "temponafila"
    t.index ["aluno_id"], name: "index_vagas_on_aluno_id"
    t.index ["fila_id"], name: "index_vagas_on_fila_id"
    t.index ["rodada_id"], name: "index_vagas_on_rodada_id"
  end

end
