-- Criação da tabela 'cadastro'
CREATE TABLE cadastro (
    nome TEXT NOT NULL,
    numero INTEGER PRIMARY KEY CHECK(numero > 0)
);

-- Criação da tabela 'log_operacoes'
CREATE TABLE log_operacoes (
    data_hora TEXT NOT NULL,
    operacao TEXT NOT NULL
);
