///// CRIAÇÃO DA TABELA

CREATE TABLE ativpedido
(
    codigopedido number NOT NULL,
    codigoproduto varchar(15),
    dtpedido timestamp NOT NULL,
	dtevento timestamp NOT NULL,
	descricaoevento varchar(100),
	PRIMARY KEY(codigopedido, dtpedido, dtevento)
);

///// CRIAÇÃO DA TABELA



///// CONSULTAS

INSERT INTO pedido VALUES(123456, SYSDATE, NULL, NULL,
 2321, '10-4030-016927', 13665, '216722Vi66293', NULL, 3.14, 26553, 26553, 3, 1,
 18.694204586, 10.108204798, 7.94999981);

INSERT INTO detalhespedido VALUES(75108, 'SO-B909-M', 3, 1.047, 0, 3.141);

INSERT INTO detalhespedido VALUES(75108, 'BK-M47B-40', 3, 1.047, 0, 3.141);

DELETE FROM detalhespedido
WHERE codigopedido = 47438 AND codigoproduto = 'BK-M47B-40';

DELETE FROM detalhespedido
WHERE codigopedido = 123456 AND codigoproduto = 'HH-1234';

UPDATE pedido
SET valortotal = 9
WHERE codigo = 123456;

UPDATE que deve dar certo:
UPDATE pedido
SET codigotransportadora = 2
WHERE codigo = 123456;


///// CONSULTAS


///// QUESTÃO 1

create or replace TRIGGER insercaoPedido
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN

:NEW.dtedido := SYSDATE;
:NEW.dtenvio := NULL;
:NEW.dtrecebimento := NULL;
:NEW.codigoconfirmacao := NULL;

INSERT INTO ativpedido VALUES(:NEW.codigo, NULL, :NEW.dtedido, SYSDATE, 'Pedido inserido com sucesso.');

END;

///// QUESTÃO 1



///// QUESTÃO 2

create or replace TRIGGER insercaoProduto
BEFORE INSERT ON detalhespedido
FOR EACH ROW
DECLARE
v_dtpedido pedido.dtedido %TYPE;
v_dtfimvenda produto.dtfimvenda %TYPE;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

SELECT dtedido
INTO v_dtpedido
FROM pedido
WHERE (codigo = :NEW.codigopedido);

SELECT dtfimvenda
INTO v_dtfimvenda
FROM produto
WHERE (codigo = :NEW.codigoproduto);

IF(v_dtfimvenda > v_dtpedido) THEN
	INSERT INTO ativpedido VALUES(:NEW.codigopedido, :NEW.codigoproduto, v_dtpedido, SYSDATE, 'Produto inserido com sucesso.');
    COMMIT;
ELSE
	INSERT INTO ativpedido VALUES(:NEW.codigopedido, :NEW.codigoproduto, v_dtpedido, SYSDATE, 'Produto não foi inserido.');
    COMMIT;
	raise_application_error(-20666, 'Produto não foi inserido.');
END IF;

END;

///// QUESTÃO 2



///// QUESTÃO 3

create or replace TRIGGER remocaoProduto
BEFORE DELETE ON detalhespedido
FOR EACH ROW
DECLARE
v_dtenvio pedido.dtenvio %TYPE;
v_dtpedido pedido.dtedido %TYPE;
v_dtfimvenda produto.dtfimvenda %TYPE;
v_qtdtotal pedido.qtdtotal %TYPE;


PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

SELECT dtenvio, dtedido
INTO v_dtenvio, v_dtpedido
FROM pedido
WHERE (pedido.codigo = :OLD.codigopedido);

SELECT dtfimvenda
INTO v_dtfimvenda
FROM produto
WHERE (produto.codigo = :OLD.codigoproduto);

IF(v_dtenvio IS NULL OR v_dtfimvenda <= SYSDATE) THEN
	INSERT INTO ativpedido VALUES(:OLD.codigopedido, :OLD.codigoproduto, v_dtpedido, SYSDATE, 'Produto removido com sucesso.');
    COMMIT;
ELSE
	INSERT INTO ativpedido VALUES(:OLD.codigopedido, :OLD.codigoproduto, v_dtpedido, SYSDATE, 'Produto não foi removido.');
    COMMIT;
	raise_application_error(-20667, 'Produto não foi removido.');
END IF;

END;

///// QUESTÃO 3



///// QUESTÃO 4

create or replace TRIGGER atualizacaoProduto
BEFORE UPDATE ON pedido
FOR EACH ROW
DECLARE
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

IF(:OLD.dtenvio IS NOT NULL OR :OLD.codigo != :NEW.codigo OR :OLD.dtedido != :NEW.dtedido
    OR :OLD.dtenvio != :NEW.dtenvio OR :OLD.dtrecebimento != :NEW.dtrecebimento
    OR :OLD.codigocliente != :NEW.codigocliente OR :OLD.contacliente != :NEW.contacliente
    OR :OLD.codigoconfirmacao != :NEW.codigoconfirmacao OR :OLD.imposto != :NEW.imposto
    OR :OLD.qtdtotal != :NEW.qtdtotal OR :OLD.valortotal != :NEW.valortotal OR :OLD.valorfrete != :NEW.valorfrete
    OR :OLD.valortotalprodutos != :NEW.valortotalprodutos) THEN
    INSERT INTO ativpedido VALUES(:NEW.codigo, NULL, :OLD.dtedido, SYSDATE, 'Pedido não foi atualizado.');
    COMMIT;
	raise_application_error(-20668, 'Pedido não foi atualizado.');
ELSE
    INSERT INTO ativpedido VALUES(:NEW.codigo, NULL, :OLD.dtedido, SYSDATE, 'Pedido atualizado com sucesso.');
    COMMIT;
END IF;

END;

///// QUESTÃO 4
