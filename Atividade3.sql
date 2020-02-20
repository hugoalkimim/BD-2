// QUESTÃO 1

CREATE OR REPLACE VIEW Estoque AS
SELECT produto.codigo, SUM(detalhespedido.quantidade)QUANTIDADE_VENDIDA
FROM produto, detalhespedido
WHERE(produto.codigo = detalhespedido.codigoproduto)
GROUP BY produto.codigo;

// QUESTÃO 1



// QUESTÃO 2

CREATE OR REPLACE VIEW PedidosOnline AS
SELECT (pedido.codigo)codigo_pedido, (produto.nome)nome_produto, (produto.codigo)codigo_produto, (cliente.codigo)codigo_cliente, 
(cliente.primeironome || ' ' || cliente.nomedomeio || ' ' || cliente.sobrenome)nome_cliente, pedido.valortotal,
(transportadora.nome)nome_transportadora, (endereco.logradouro || ' ' || endereco.complemento || ' ' || endereco.cidade
|| ' ' || endereco.estado || ' ' || endereco.pais)endereco
FROM pedido 
INNER JOIN detalhespedido ON (detalhespedido.codigopedido = pedido.codigo)
INNER JOIN produto ON (detalhespedido.codigoproduto = produto.codigo)
INNER JOIN cliente ON (pedido.codigocliente = cliente.codigo)
INNER JOIN endereco ON (pedido.enderecoentrega = endereco.ID)
INNER JOIN transportadora ON (pedido.codigotransportadora = transportadora.codigo)
WHERE (pedido.codigovendedor IS NULL);

// QUESTÃO 2



// QUESTÃO 3

CREATE OR REPLACE VIEW PedidosPresenciais AS
SELECT (pedido.codigo)codigo_pedido, (produto.nome)nome_produto, (produto.codigo)codigo_produto, (cliente.codigo)codigo_cliente, 
(cliente.primeironome || ' ' || cliente.nomedomeio || ' ' || cliente.sobrenome)nome_cliente, pedido.valortotal,
(transportadora.nome)nome_transportadora, (endereco.logradouro || ' ' || endereco.complemento || ' ' || endereco.cidade
|| ' ' || endereco.estado || ' ' || endereco.pais)endereco
FROM pedido 
INNER JOIN detalhespedido ON (detalhespedido.codigopedido = pedido.codigo)
INNER JOIN produto ON (detalhespedido.codigoproduto = produto.codigo)
INNER JOIN cliente ON (pedido.codigocliente = cliente.codigo)
INNER JOIN endereco ON (pedido.enderecoentrega = endereco.ID)
INNER JOIN transportadora ON (pedido.codigotransportadora = transportadora.codigo)
WHERE (pedido.codigovendedor IS NOT NULL);

create or replace TRIGGER InsercaoPedidosPresenciais
INSTEAD OF INSERT ON PedidosPresenciais
FOR EACH ROW
DECLARE
v_ctransportadora transportadora.codigo %TYPE;

CURSOR c_ptransportadora IS
SELECT transportadora.codigo
FROM transportadora
WHERE (transportadora.nome = :NEW.nome_transportadora);

BEGIN

OPEN c_ptransportadora;
FETCH c_ptransportadora INTO v_ctransportadora;

IF c_ptransportadora %NOTFOUND THEN

SELECT MAX(transportadora.codigo)
INTO v_ctransportadora
FROM transportadora;

v_ctransportadora := v_ctransportadora + 1;
INSERT INTO transportadora VALUES(v_ctransportadora, :NEW.nome_transportadora, 0.0, 0.0);

END IF;

CLOSE c_ptransportadora;

INSERT INTO produto VALUES(:NEW.codigo_produto, :NEW.nome_produto, NULL, 0, :NEW.valortotal, NULL, NULL, NULL, NULL, SYSDATE, NULL);
INSERT INTO detalhesPedido VALUES(:NEW.codigo_pedido, :NEW.codigo_produto, 1, :NEW.valortotal, 0, :NEW.valortotal);

END;

INSERT INTO PedidosPresenciais VALUES(71894, 'ProdutoAleatorio3000', 'BR-127', 12687, 'Elizabeth E Gonzales', 4.13, 'OVERNIGHT J-FAST', '2345 North Freeway  Houston Texas United States');
INSERT INTO PedidosPresenciais VALUES(71894, 'ProdutoAleatorio4000', 'BR-128', 12687, 'Elizabeth E Gonzales', 4.13, 'OVERNIGHT J-FAST', '2345 North Freeway  Houston Texas United States');

// QUESTÃO 3
