-- EVENTO CRIADO
CREATE TABLE Evento (
  id_evento          SERIAL PRIMARY KEY NOT NULL,
  nome_evento        VARCHAR(255)       NOT NULL,
  valor_total_evento FLOAT,
  data_criacao       TIMESTAMP          NOT NULL,
  status_evento      VARCHAR(255)       NOT NULL CHECK (status_evento = 'EM_ANDAMENTO' OR
                                                        status_evento = 'INSCRICOES_ABERTAS' OR
                                                        status_evento = 'FECHADO' OR
                                                        status_evento = 'CANCELADO'),
  id_usuario        INT                NOT NULL REFERENCES Usuario (id_usuario),
  id_tipo_evento     INT                NOT NULL REFERENCES TipoEvento (id_tipo_evento),
  periodo_evento     INT                NOT NULL REFERENCES Periodo (id_periodo)
);

-- ATIVIDADE CRIADA
CREATE TABLE Atividade (
  id_atividade        SERIAL PRIMARY KEY NOT NULL,
  titulo_atividade    VARCHAR(25)        NOT NULL,
  descricao_atividade VARCHAR(255)       NOT NULL,
  quantidade_vagas    INT                NOT NULL,
  valor_atividade     FLOAT              NOT NULL,
  id_periodo          INT                NOT NULL REFERENCES Periodo (id_periodo),
  id_evento           INT                NOT NULL REFERENCES Evento (id_evento)
);

INSERT INTO Atividade VALUES (DEFAULT, 'Atividade de Exbi��o', 'Atividade de introdu��o ao Evento', 10, 20.00, 1, 1);
SELECT * from Atividade;
DELETE from Atividade;

-- PERIODO CRIADO
CREATE TABLE Periodo (
  id_periodo     SERIAL PRIMARY KEY NOT NULL,
  periodo_inicio TIMESTAMP          NOT NULL,
  periodo_fim    TIMESTAMP          NOT NULL
);

-- TIPO EVENTO CRIADO
CREATE TABLE TipoEvento (
  id_tipo_evento        SERIAL PRIMARY KEY NOT NULL,
  descricao_tipo_evento VARCHAR(255)       NOT NULL
);

-- EVENTO INSTITUICAO CRIADO
CREATE TABLE EventoInstituicao (
  id_evento_instituicao SERIAL PRIMARY KEY NOT NULL,
  id_evento             INT                NOT NULL REFERENCES Evento (id_evento),
  id_instituicao        INT                NOT NULL REFERENCES Instituicao (id_instituicao)
);

-- INSTITUICAO CRIADA
CREATE TABLE Instituicao (
  id_instituicao   SERIAL PRIMARY KEY NOT NULL,
  nome_instituicao VARCHAR(255)       NOT NULL
);

-- USUARIO CRIADO
CREATE TABLE Usuario (
  id_usuario   SERIAL PRIMARY KEY NOT NULL,
  nome         VARCHAR(255)       NOT NULL,
  email        VARCHAR(255)       NOT NULL,
  data_entrada TIMESTAMP          NOT NULL
);

-- GRUPO USUARIO CRIADO
CREATE TABLE GrupoUsuario (
  id_grupo_usuario SERIAL PRIMARY KEY NOT NULL,
  id_grupo         INT                NOT NULL REFERENCES Grupo (id_grupo),
  id_usuario       INT                NOT NULL REFERENCES Usuario (id_usuario)
);

-- GRUPO CRIADO
CREATE TABLE Grupo (
  id_grupo SERIAL PRIMARY KEY NOT NULL,
  nome     VARCHAR(25)        NOT NULL
);

-- INSCRICAO EM UM EVENTO, A INSCRICAO � FEITA EM TODAS AS ATIVIDADES DO EVENTO
-- CRIADO
-- CREATE TABLE InscricaoEvento (
--   id_inscricao_evento              SERIAL PRIMARY KEY NOT NULL,
--   data_inscricao                   TIMESTAMP          NOT NULL,
--   valor_inscricao                  FLOAT              NOT NULL,
--   status_pagamento                 VARCHAR(255)       NOT NULL CHECK (status_pagamento = 'PAGO' OR
--                                                                       status_pagamento = 'ABERTO'),
--   id_evento                        INT                NOT NULL REFERENCES Evento (id_evento),
--   id_grupo                         INT                NOT NULL REFERENCES Grupo (id_grupo),
--   data_vencimento_pagamento_evento TIMESTAMP          NOT NULL
-- );

-- INSCRICAO NA ATIVIDADE
-- CRIADO
CREATE TABLE Inscricao (
  id_inscricao    SERIAL PRIMARY KEY NOT NULL,
  valor_inscricao           FLOAT              NOT NULL,
  data_vencimento_pagamento TIMESTAMP          NOT NULL,
  status_pagamento          VARCHAR(255)       NOT NULL CHECK (status_pagamento = 'PAGO' OR
                                                               status_pagamento = 'ABERTO'),
  id_grupo                  INT                NOT NULL REFERENCES Grupo (id_grupo)
);

-- CRIADO
CREATE TABLE ItemInscricao (
  id_item_inscricao      SERIAL PRIMARY KEY NOT NULL,
  valor_item_inscricao   FLOAT              NOT NULL,
  id_atividade           INT                NOT NULL REFERENCES Atividade (id_atividade),
  id_inscricao INT                NOT NULL REFERENCES Inscricao (id_inscricao)
);

-- INSERIR GENERICO
CREATE OR REPLACE FUNCTION inserir(tabela TEXT, valores TEXT) RETURNS VOID AS $inserir$
DECLARE query TEXT := 'INSERT INTO ' || tabela || ' VALUES (' || valores || ');';
BEGIN
  IF tabela = 'inscricao' THEN
    RAISE EXCEPTION 'Voce n�o pode Realizar uma Inscricao por Aqui';
  END IF;
  EXECUTE query;
END;
$inserir$ LANGUAGE plpgsql;

SELECT inserir('grupo', 'DEFAULT, ''Grupo Da Fulia''');
SELECT * FROM grupo;

-- REMOVE GENERICO
-- VERIFICA FUNCAO, PODE ESTAR INCORRETA

CREATE OR REPLACE FUNCTION remover(tabela TEXT, condicao TEXT) RETURNS VOID AS $remover$
DECLARE query TEXT := 'DELETE FROM ' || tabela || ' WHERE ' || condicao || ';';
BEGIN
  EXECUTE query;
END;
$remover$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION criar_inscricao(id_grupo INT) RETURNS VOID AS $criar_inscricao$
BEGIN
  --   data de vencimento pagamento sempre 30 dias depois da data atual
  INSERT INTO Inscricao VALUES (default, 0, now() + INTERVAL '30 days', 'ABERTO', $1);
END;
$criar_inscricao$ LANGUAGE plpgsql;


-- PARTICIPAR GRUPO
CREATE OR REPLACE FUNCTION participar_grupo(id_grupo_participar TEXT, id_usuario_participar TEXT) RETURNS VOID AS $participar_grupo$
  DECLARE
    criar_grupo_usuairo TEXT := 'insert into GrupoUsuario values(DEFAULT, ' || id_grupo_participar || ',' || id_usuario_participar || ' )';
  BEGIN
    EXECUTE criar_grupo_usuairo;
  END;
$participar_grupo$ LANGUAGE plpgsql;

-- INSCRICAO EM EVENTO;
CREATE OR REPLACE FUNCTION inscricao_completa(id_grupo TEXT, id_evento_inscricao TEXT) RETURNS VOID AS $inscricao_completa$
DECLARE
  id_evento_inscricao_atividade INTEGER := id_evento_inscricao;
  criar_inscricao TEXT := 'select criar_inscricao('|| ($1) ||')';
  i INTEGER;
  valor_atividades FLOAT := 0;
BEGIN
  EXECUTE criar_inscricao;
  CREATE OR REPLACE VIEW ids_atividades AS SELECT id_atividade FROM Atividade WHERE id_evento = 1; -- CORRIGIR
  FOR i IN (SELECT * FROM ids_atividades) LOOP
    INSERT INTO ItemInscricao VALUES (DEFAULT,
                                      (SELECT valor_atividade FROM atividade WHERE Atividade.id_atividade = i),
                                      (SELECT id_atividade FROM atividade WHERE Atividade.id_atividade = i),
                                      (SELECT max(id_inscricao) FROM Inscricao));
    valor_atividades := valor_atividades + (SELECT valor_atividade FROM atividade WHERE Atividade.id_atividade = i);
    update Atividade set quantidade_vagas = ((SELECT quantidade_vagas from atividade where id_atividade = i) - 1) where id_atividade = i;
  END LOOP;
  CREATE OR REPLACE view id_insc as SELECT max(id_inscricao) from Inscricao;
  UPDATE Inscricao SET valor_inscricao = valor_atividades WHERE id_inscricao IN (SELECT * FROM id_insc);
--   SELECT aplicar_desconto($1,
--                           (SELECT cast(id_inscricao as text) FROM Inscricao WHERE id_inscricao IN (SELECT * FROM id_insc)),
--                           (SELECT cast(valor_inscricao as text) FROM inscricao WHERE id_inscricao IN (SELECT * FROM id_insc)));
END;
$inscricao_completa$ LANGUAGE plpgsql;

select inscricao_completa('9', '1');
CREATE OR REPLACE FUNCTION inscricao_por_atividade(id_grupo_inscricao TEXT, id_atividade_inscricao TEXT) RETURNS VOID AS $inscricao_por_atividade$
DECLARE
  criar_inscricao      TEXT := 'select criar_inscricao(' || id_grupo_inscricao || ')';
  criar_item_inscricao TEXT :=
  'insert into ItemInscricao values (default, (select valor_atividade from atividade where id_atividade = ' ||
  id_atividade_inscricao || '), ' || id_atividade_inscricao || ', (select max(id_inscricao) from inscricao));';
  quantidade_vagas     TEXT :=
  'update atividade set quantidade_vagas = ((select quantidade_vagas from atividade where id_atividade = ' ||
  id_atividade_inscricao || ') - 1) where id_atividade = ' || id_atividade_inscricao;
--   atualizar_valor_inscricao TEXT :=
--   'update Inscricao set valor_inscricao = (select valor_atividade from atividade where id_atividade = ' ||
--   id_atividade_inscricao || ') where id_inscricao = ' || ||';';
BEGIN
  EXECUTE criar_inscricao;
  EXECUTE criar_item_inscricao;
  EXECUTE quantidade_vagas;
--   EXECUTE atualizar_valor_inscricao;
END;
$inscricao_por_atividade$ LANGUAGE plpgsql;
SELECT inscricao_por_atividade('9','3');


CREATE OR REPLACE FUNCTION associar_evento_instituicao(id_evento_associar TEXT, id_instituicao_associar TEXT) RETURNS VOID AS $associar_evento_instituicao$
  DECLARE
    criar_instituicao_evento TEXT := 'insert into EventoInstituicao values (default, ' || id_evento_associar || ', ' || id_instituicao_associar || ')';
  BEGIN
    EXECUTE criar_instituicao_evento;
  END;
$associar_evento_instituicao$ LANGUAGE plpgsql;
-- drop FUNCTION associar_evento_instituicao(text,text);

CREATE OR REPLACE FUNCTION aplicar_desconto(id_grupo_desconto TEXT, id_inscricao_desconto TEXT) RETURNS void AS $aplicar_desconto$
DECLARE
  grupo_desconto INT := id_grupo_desconto;
  inscricao_desconto_10 TEXT :=
  'update Inscricao set valor_inscricao = (select valor_inscricao from Inscricao where id_inscricao = ' ||
  id_inscricao_desconto || ') - ((select valor_inscricao from Inscricao where id_inscricao = ' || id_inscricao_desconto
  || ') * 0.10) where id_inscricao = ' || id_inscricao_desconto || ';';
  inscricao_desconto_20 TEXT :=
  'update Inscricao set valor_inscricao = (select valor_inscricao from Inscricao where id_inscricao = ' ||
  id_inscricao_desconto || ') - ((select valor_inscricao from Inscricao where id_inscricao = ' || id_inscricao_desconto
  || ') * 0.20) where id_inscricao = ' || id_inscricao_desconto || ';';
--   id_grupo_desc INTEGER := id_grupo_desconto;
BEGIN
--   ALTERAR METODO
  IF (SELECT count(*) FROM GrupoUsuario WHERE id_grupo = grupo_desconto) <= 1 THEN
    EXECUTE inscricao_desconto_10;
  END IF;
  IF (SELECT count(*) FROM GrupoUsuario WHERE id_grupo = grupo_desconto) >= 20  THEN
    EXECUTE inscricao_desconto_20;
  END IF;
END;
$aplicar_desconto$ LANGUAGE plpgsql;

SELECT aplicar_desconto('8', '50');

-- CRIANDO TRIGGERS
-- Verificando email usuario
CREATE OR REPLACE FUNCTION validar_cadastro_usuario() RETURNS TRIGGER AS $validar_cadastro_usuario$
 BEGIN
   IF new.email IN (SELECT email FROM usuario) THEN
     RAISE EXCEPTION 'O Email Cadastrado ja Esta Em Uso';
   END IF;
 END;
$validar_cadastro_usuario$ language plpgsql;
CREATE TRIGGER trigger_cadastro_usuario BEFORE INSERT OR UPDATE ON Usuario FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_usuario();

-- drop FUNCTION validar_cadastro_atividade();
-- drop TRIGGER trigger_cadastro_atividade on Atividade;

-- validando atividade
-- TO DO BUGADO ESSA PORRA
select * from Atividade;
SELECT * from Inscricao;
SELECT * from ItemInscricao;
CREATE OR REPLACE FUNCTION validar_cadastro_atividade() RETURNS TRIGGER AS $validar_cadastro_atividade$
  BEGIN
    IF (SELECT periodo_inicio FROM Periodo WHERE id_periodo in
                                                 (SELECT id_periodo FROM Evento where Evento.id_evento = new.id_evento)) >
       (SELECT periodo_inicio FROM periodo WHERE Atividade.id_periodo = new.id_periodo) THEN
      RAISE EXCEPTION 'O periodo da Atividade � Inferior a Data de Inicio do Evento';
    END IF;
    IF (SELECT periodo_fim FROM Periodo WHERE id_periodo in
                                                 (SELECT id_periodo FROM Evento where Evento.id_evento = new.id_evento)) <
       (SELECT periodo_fim FROM periodo WHERE Atividade.id_periodo = new.id_periodo) THEN
      RAISE EXCEPTION 'A data para Termino da Atividade Corresponde a uma Data Apos o Fim do Evento';
    END IF;
    IF (SELECT periodo_fim FROM Periodo WHERE id_periodo in
                                                 (SELECT id_periodo FROM Evento where Evento.id_evento = new.id_evento)) <
       (SELECT periodo_inicio FROM periodo where Atividade.id_periodo = new.id_periodo) THEN
      RAISE EXCEPTION 'O Periodo Informado Refere - se a uma Data Depois do Evento';
    END IF;
    IF new.id_evento NOT IN (SELECT id_evento FROM Evento) THEN
      raise EXCEPTION 'A Evento Informado n�o esta Cadastrado';
    END IF;
    IF new.id_periodo NOT IN (SELECT id_periodo FROM Periodo) THEN
      raise EXCEPTION 'O Periodo Informado n�o esta Cadastrado';
    END IF;
    IF new.valor_atividade < 0 THEN
      RAISE EXCEPTION 'O valor da Atividade n�o pode ser Inferior ou igual a Zero';
    END IF;
    IF new.quantidade_vagas < 0 THEN
      RAISE EXCEPTION 'O Numero de Vagas Informado � Invalido';
    END IF;
    IF new.titulo_atividade IN (SELECT descricao_atividade FROM Atividade) THEN
      RAISE EXCEPTION 'A Atividade Ja foi Cadastrada';
    END IF;
    UPDATE Evento SET valor_total_evento = (SELECT valor_total_evento FROM Evento WHERE Evento.id_evento = new.id_evento) + new.valor_atividade WHERE id_evento = new.id_evento;
    RETURN new;
  END;
$validar_cadastro_atividade$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_cadastro_atividade BEFORE INSERT OR UPDATE ON Atividade FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_atividade();

-- validando grupo
CREATE OR REPLACE FUNCTION validar_cadastro_grupo() RETURNS TRIGGER AS $validar_cadastro_grupo$
 BEGIN
   IF new.nome IN (SELECT nome FROM grupo) THEN
     RAISE EXCEPTION 'Esse Nome de Grupo ja foi Cadastrado';
   END IF;
   RETURN new;
 END;
$validar_cadastro_grupo$ language plpgsql;
CREATE TRIGGER trigger_cadastro_grupo BEFORE INSERT OR UPDATE ON Grupo FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_grupo();

-- validando periodo
CREATE OR REPLACE FUNCTION validar_periodo() RETURNS TRIGGER AS $validar_periodo$
  BEGIN
    IF new.periodo_fim < new.periodo_inicio then
      RAISE EXCEPTION 'A data de Inicio � Anterior a Data de Fim';
    END IF;
    IF new.periodo_inicio < now() then
      RAISE EXCEPTION 'A data de Inicio � Anterior a Data Atual';
    END IF;
    IF new.periodo_fim < now() then
      RAISE EXCEPTION 'A data de Fim � Anterior a Data Atual';
    END IF;
    RETURN new;
  END;
$validar_periodo$ language plpgsql;
CREATE TRIGGER trigger_cadastro_periodo BEFORE INSERT OR UPDATE ON Periodo FOR EACH ROW EXECUTE PROCEDURE validar_periodo();

-- alter TABLE Evento RENAME COLUMN dono_evento to id_usuario;

-- validando evento
select * from Evento;
CREATE OR REPLACE FUNCTION validar_cadastro_evento() RETURNS TRIGGER AS $validar_cadastro_evento$
  BEGIN
    IF new.id_tipo_evento NOT IN (SELECT id_tipo_evento from TipoEvento) THEN
      RAISE EXCEPTION 'O TipoEvento Informdado n�o foi Cadastrado';
    END IF;
    IF new.id_periodo NOT IN (SELECT id_periodo from Periodo) THEN
      RAISE EXCEPTION 'O Periodo Informdado n�o foi Cadastrado';
    END IF;
    IF new.id_usuario NOT IN (SELECT id_usuario from Usuario) THEN
      RAISE EXCEPTION 'O Usuario Informdado n�o foi Cadastrado';
    END IF;
    IF new.nome_evento in (SELECT nome_evento FROM Evento) then
      RAISE EXCEPTION 'Esse nome de Evento ja foi Cadastrado';
    END IF;
    IF new.valor_total_evento < 0 THEN
      RAISE EXCEPTION 'O Valor Total do Evento n�o pode Ser Negativo';
    END IF;
    IF new.valor_total_evento > 0 THEN
      RAISE EXCEPTION 'O Valor Total do Evento Precisa ser Zero';
    END IF;
    IF new.data_criacao < now() THEN
      RAISE EXCEPTION 'A Data do Evento N�o pode Ser Inferior a Data Atual';
    END IF;
    return new;
  END;
$validar_cadastro_evento$ language plpgsql;
CREATE TRIGGER trigger_cadastro_evento BEFORE INSERT OR UPDATE ON Evento FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_evento();

-- validando instituicao
CREATE OR REPLACE FUNCTION validar_cadastro_instituicao() RETURNS TRIGGER AS $validar_cadastro_instituicao$
  BEGIN
    IF new.nome_instituicao in (SELECT nome_instituicao FROM Instituicao) then
      RAISE EXCEPTION 'Esse nome de Instituicao ja foi Cadastrado';
    END IF;
    return new;
  END;
$validar_cadastro_instituicao$ language plpgsql;
CREATE TRIGGER trigger_cadastro_instituicao BEFORE INSERT OR UPDATE ON Inscricao FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_instituicao();

-- drop TRIGGER trigger_cadastro_instituicao on Evento;

-- validando Inscricao em Evento
select * from Inscricao;
CREATE OR REPLACE FUNCTION validar_cadastro_inscricao_evento() RETURNS TRIGGER AS $validar_cadastro_inscricao_evento$
  BEGIN
    IF new.id_grupo NOT IN (SELECT id_grupo FROM grupo) THEN
      raise EXCEPTION 'A Grupo Informado n�o esta Cadastrado';
    END IF;
    if new.data_vencimento_pagamento < now() then
      raise EXCEPTION 'A data De Cria��o n�o pode ser Inferior a Data Atual';
    END IF;
    RETURN new;
  END;
$validar_cadastro_inscricao_evento$ language plpgsql;
CREATE TRIGGER trigger_cadastro_inscricao BEFORE INSERT OR UPDATE ON Inscricao FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_inscricao_evento();

-- VALIDADANDO CADASTRO ITEM INSCRICAO
select * from ItemInscricao;
SELECT * from Inscricao;
CREATE OR REPLACE FUNCTION validar_cadastro_item_inscricao() RETURNS TRIGGER AS $validar_cadastro_item_inscricao$
BEGIN
  IF new.id_inscricao not in (SELECT id_inscricao from Inscricao) THEN
    RAISE EXCEPTION 'A Inscricao Informada n�o foi Cadastrada';
  END IF;
  IF new.id_atividade not in (SELECT id_atividade from Atividade) THEN
    RAISE EXCEPTION 'A Atividade Informada n�o foi Cadastrada';
  END IF;
  IF new.id_atividade IN (SELECT id_atividade FROM iteminscricao) THEN
    RAISE EXCEPTION 'Voc� J� se Inscreveu nessa Atividade';
  END IF;
  IF (SELECT quantidade_vagas FROM Atividade WHERE id_atividade = new.id_atividade) = 0 THEN
    DELETE from Inscricao WHERE id_inscricao IN (SELECT max(id_inscricao) FROM inscricao);
    RAISE EXCEPTION 'A Atividade n�o Possui Vagas Em Aberto';
  END IF;
  IF new.id_atividade NOT IN (SELECT Atividade.id_atividade FROM Atividade) THEN
    RAISE EXCEPTION 'A Atividade Informada n�o foi Cadastrada';
  END IF;
  RETURN new;
END;
$validar_cadastro_item_inscricao$ language plpgsql;
CREATE TRIGGER trigger_cadastro_item_inscricao BEFORE INSERT OR UPDATE ON ItemInscricao FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_item_inscricao();

-- drop TRIGGER trigger_cadastro_inscricao on Inscricao;
-- drop FUNCTION validar_cadastro_inscricao_evento();

CREATE OR REPLACE FUNCTION validar_cadastro_evento_instituicao() RETURNS TRIGGER AS $validar_cadastro_evento_instituicao$
  BEGIN
    IF new.id_evento NOT IN (SELECT id_evento from Evento) THEN
      RAISE EXCEPTION 'O Evento Informado n�o foi Cadastrado';
    END IF;
    IF new.id_instituicao NOT IN (SELECT id_instituicao from Instituicao) THEN
      RAISE EXCEPTION 'A Instituicao Informada n�o foi Cadastrada';
    END IF;
  END;
$validar_cadastro_evento_instituicao$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_cadastro_evento_instituicao BEFORE INSERT OR UPDATE ON EventoInstituicao FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_evento_instituicao();

CREATE OR REPLACE FUNCTION validar_cadastro_grupo_usuario() RETURNS TRIGGER AS $validar_cadastro_grupo_usuario$
  BEGIN
    IF new.id_grupo NOT IN (SELECT id_grupo FROM Grupo) THEN
      RAISE EXCEPTION 'O grupo Informado n�o foi Cadastrado';
    END IF;
    IF new.id_usuario NOT IN (SELECT id_usuario FROM Usuario) THEN
      RAISE EXCEPTION 'O Usuario Informado n�o foi Cadastrado';
    END IF;
  END;
$validar_cadastro_grupo_usuario$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_cadastro_grupo_usuario BEFORE INSERT OR UPDATE ON GrupoUsuario FOR EACH ROW EXECUTE PROCEDURE validar_cadastro_grupo_usuario();


-- ============================================================

-- POPULAR BANCO DE DADOS

-- CRIANDO USUARIO
SELECT inserir('Usuario', ('default, ''Kassio Lucas de Holanda'', ''kassioholandaleodido@gmail.com'', now()'));
SELECT inserir('Usuario', ('default, ''Kaio Lucas de Holanda'', ''kaioluks@gmail.com'', now()'));
SELECT * FROM usuario;

-- CRIANDO GRUPO
SELECT inserir('Grupo', 'default, ''Grupo Da Fulia''');
SELECT inserir('Grupo', 'default, ''Grupo Da Matematica''');
SELECT * FROM Grupo;

-- CRIANDO INSTITUICAO
SELECT inserir('Instituicao', 'default, ''IFPI''');
SELECT inserir('Instituicao', 'default, ''Prefeitura de Teresina''');
SELECT * FROM Instituicao;

-- CRIANDO TIPO EVENTO
SELECT inserir('TipoEvento', 'default, ''Palestras'' ');
SELECT inserir('TipoEvento', 'default, ''Mini Cursos'' ');
SELECT * FROM TipoEvento;

-- CRIANDO PERIODO
SELECT inserir('Periodo', 'default, now(), now() + INTERVAL ''20 days'' ');
SELECT inserir('Periodo', 'default, now(), now() + INTERVAL ''15 days'' ');
SELECT * FROM Periodo;

-- CRIANDO EVENTO
SELECT inserir('Evento', 'default, ''Casa da Matematica'', 0, now(), ''EM_ANDAMENTO'', 4, 3, 4 ');
SELECT inserir('Evento', 'default, ''FIFA'', 0, now(), ''EM_ANDAMENTO'', 2, 3, 3 ');
SELECT * FROM Evento;

-- CRIANDO ATIVIDADE
SELECT inserir('Atividade', 'default, ''Aprendendo a Bater Falta'', ''Nessa Atividade voc� Aprendera a Bater Falta no FIFA'', 15, 35.50, 1, 7');
SELECT inserir('Atividade', 'default, ''Matematica - Matrizes'', ''Nessa Atividade voc� Aprendera um Pouco Sobre Matrizes'', 15, 35.50, 3, 7');
SELECT * FROM Atividade;

-- ASSOCIAR EVENTO INSTITUICAO
SELECT associar_evento_instituicao('7','1');
SELECT associar_evento_instituicao('6','2');
SELECT * FROM EventoInstituicao;

-- PARTICIPAR GRUPO
SELECT participar_grupo('10', '2');
SELECT participar_grupo('10', '4');
SELECT * FROM GrupoUsuario;

-- INSCRICAO POR ATIVIDADE

-- INSCRICAO POR EVENTO