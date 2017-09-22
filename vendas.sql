# Criar banco de dados
DROP DATABASE IF EXISTS Vendas;
CREATE DATABASE Vendas;
USE Vendas;

# Criar tabelas
DROP TABLE IF EXISTS Clientes;
CREATE TABLE Clientes (
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (Codigo),
    Nome VARCHAR(30) NOT NULL UNIQUE
);
DROP TABLE IF EXISTS Produtos;
CREATE TABLE Produtos(
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (Codigo),
    Nome VARCHAR(30) NOT NULL UNIQUE
);
DROP TABLE IF EXISTS Compras;
CREATE TABLE Compras (
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (Codigo),
    ClienteCodigo INT UNSIGNED NOT NULL,
    FOREIGN KEY (ClienteCodigo) REFERENCES Clientes(Codigo),
    ProdutoCodigo INT UNSIGNED NOT NULL,
    FOREIGN KEY (ProdutoCodigo) REFERENCES Produtos(Codigo),
    Data TIMESTAMP,
    Valor REAL
);
DROP TABLE IF EXISTS Pagamentos;
CREATE TABLE Pagamentos (
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (Codigo),
    CompraCodigo INT UNSIGNED NOT NULL,
    FOREIGN KEY (CompraCodigo) REFERENCES Compras(Codigo),
    Data TIMESTAMP,
    Valor REAL
);

#Inserir Clientes
INSERT INTO Clientes 
(Nome) VALUES
("Fulano de Tal"),
("Cicrano de Tal"),
("Beltrano de Tal");

#Inserir Produtos
INSERT INTO Produtos
(Nome) VALUES
("Cafe"),
("Coxinha"),
("Esfirra"),
("Pastel"),
("Quibe"),
("Sanduiche Natural"),
("Suco"),
("Refresco"),
("Refrigerante"),
("Pao de queijo");

# Criar PROCEDURE que encontra o codigo do cliente
DROP PROCEDURE IF EXISTS CODIGOCLIENTE;
DELIMITER //
CREATE PROCEDURE CODIGOCLIENTE(
  IN NomeCliente VARCHAR(30),
  OUT CodigoCliente INT UNSIGNED)
BEGIN
  SELECT Codigo INTO CodigoCliente FROM Clientes 
  WHERE Nome=NomeCliente LIMIT 1;
END //
DELIMITER ;

# Criar PROCEDURE que encontra o codigo do produto
DROP PROCEDURE IF EXISTS CODIGOPRODUTO;
DELIMITER //
CREATE PROCEDURE CODIGOPRODUTO(
  IN NomeProduto VARCHAR(30),
  OUT CodigoProduto INT UNSIGNED)
BEGIN
  SELECT Codigo INTO CodigoProduto FROM Produtos 
  WHERE Nome=NomeProduto LIMIT 1;
END //
DELIMITER ;


## Inserir compras ##

#Encontrar codigo do cliente 
CALL CODIGOCLIENTE("Fulano de Tal",@CodigoCliente);
#Encontrar codigo do produto 
CALL CODIGOPRODUTO("Pastel",@CodigoProduto);
#Inserir compra
INSERT INTO Compras (ClienteCodigo,ProdutoCodigo,Valor) 
VALUES (@CodigoCliente,@CodigoProduto,2.5);

CALL CODIGOCLIENTE("Fulano de Tal",@CodigoCliente);
INSERT INTO Compras 
(ClienteCodigo,ProdutoCodigo,Valor) VALUES 
(@CodigoCliente,1,0.5),
(@CodigoCliente,3,2.5),
(@CodigoCliente,5,0.75),
(@CodigoCliente,7,1.5);

#Encontrar codigo do cliente 
CALL CODIGOCLIENTE("Cicrano de Tal",@CodigoCliente);
#Inserir compra
INSERT INTO Compras 
(ClienteCodigo,ProdutoCodigo,Valor) VALUES 
(@CodigoCliente,1,0.5),
(@CodigoCliente,2,2.5),
(@CodigoCliente,3,2.5),
(@CodigoCliente,4,1.5),
(@CodigoCliente,5,0.75);

#Encontrar codigo do cliente 
CALL CODIGOCLIENTE("Beltrano de Tal",@CodigoCliente);
#Inserir compra
INSERT INTO Compras 
(ClienteCodigo,ProdutoCodigo,Valor) VALUES 
(@CodigoCliente,6,3.5),
(@CodigoCliente,7,1.5),
(@CodigoCliente,8,1.0),
(@CodigoCliente,9,0.5),
(@CodigoCliente,10,2.0);

#Encontrar codigo do cliente 
CALL CODIGOCLIENTE("Cicrano de Tal",@CodigoCliente);
#Inserir compra
INSERT INTO Compras 
(ClienteCodigo,ProdutoCodigo,Valor) VALUES 
(@CodigoCliente,4,1.5),
(@CodigoCliente,6,3.5),
(@CodigoCliente,8,1.0),
(@CodigoCliente,10,2.0);

## Criar VIEWs ##
#Todas as Vendas
CREATE VIEW Vendas AS 
SELECT Clientes.Nome AS Cliente,
       Produtos.Nome AS Produto,
       Compras.Valor AS Valor,
       Compras.Data AS Data
FROM Compras
  INNER JOIN Clientes 
    ON Clientes.Codigo = Compras.ClienteCodigo
  INNER JOIN Produtos
    ON Produtos.Codigo = Compras.ProdutoCodigo;

#Vendas agrupadas por cliente
CREATE VIEW VendasCliente AS 
SELECT Clientes.Codigo AS ClienteCodigo,
       Clientes.Nome AS Cliente,
       Compras.Codigo AS CompraCodigo,
       Compras.Data AS CompraData,
       SUM(Compras.Valor) AS Valor
FROM Compras
  INNER JOIN Clientes 
    ON Clientes.Codigo = Compras.ClienteCodigo
GROUP BY Cliente;

#Vendas agrupadas por data
CREATE VIEW VendasData AS 
SELECT Clientes.Nome AS Cliente,
       Compras.Codigo AS CompraCodigo,
       COUNT(Compras.Valor) AS Itens,
       SUM(Compras.Valor) AS Valor,
       Compras.Data AS CompraData
FROM Compras
  INNER JOIN Clientes
    ON Clientes.Codigo = Compras.ClienteCodigo
GROUP BY Data;

CREATE VIEW ComprasNaoPagas AS
SELECT *
FROM VendasData
WHERE CompraCodigo NOT IN 
      (SELECT CompraCodigo
       FROM Pagamentos);

INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(1,2.5);

CREATE VIEW PagamentosData AS
SELECT VendasData.Cliente AS Cliente,
       VendasData.CompraCodigo AS CompraCodigo,
       VendasData.CompraData AS CompraData,
       VendasData.Valor AS CompraValor,
       Pagamentos.Codigo AS PagamentoCodigo,
       Pagamentos.Data AS PagamentoData,
       SUM(Pagamentos.Valor) AS PagamentoValor
FROM Pagamentos
INNER JOIN VendasData
ON VendasData.CompraCodigo = Pagamentos.CompraCodigo
GROUP BY CompraData;

INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(6,5);

CREATE VIEW ComprasPagas AS
SELECT VendasData.*,
       PagamentosData.PagamentoData
FROM VendasData
INNER JOIN PagamentosData
ON PagamentosData.CompraCodigo = VendasData.CompraCodigo
WHERE PagamentosData.PagamentoValor >= VendasData.Valor;

INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(6,2.75);

INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(11,5);

CREATE VIEW ComprasPendentes AS
SELECT VendasData.*,
       PagamentosData.PagamentoValor AS ValorPago,
       PagamentosData.PagamentoData
FROM VendasData
INNER JOIN PagamentosData
ON PagamentosData.CompraCodigo = VendasData.CompraCodigo
WHERE PagamentosData.PagamentoValor < VendasData.Valor;

CREATE VIEW ComprasEmAberto AS
SELECT Cliente,
       CompraCodigo,
       CompraData,
       Valor,
       ValorPago 
FROM ComprasPendentes
UNION
SELECT Cliente,
       CompraCodigo,
       CompraData,
       Valor,
       0 AS ValorPago
FROM ComprasNaoPagas;

# Criar PROCEDURE que encontra o codigo de uma compra em aberto
#DROP PROCEDURE IF EXISTS CODIGOCOMPRA;
DELIMITER //
CREATE PROCEDURE CODIGOCOMPRA(
  IN NomeCliente VARCHAR(30),
  OUT CodigoCompra INT UNSIGNED)
BEGIN
  SELECT CompraCodigo INTO CodigoCompra FROM ComprasEmAberto 
  WHERE Cliente=NomeCliente LIMIT 1;
END //
DELIMITER ;

CALL CODIGOCOMPRA("Beltrano de Tal",@CodigoCompra);
INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(@CodigoCompra,3);

CALL CODIGOCOMPRA("Fulano de Tal",@CodigoCompra);
INSERT INTO Pagamentos
(CompraCodigo,Valor) VALUES
(@CodigoCompra,5.25);
