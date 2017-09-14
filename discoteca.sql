# Criar banco de dados
DROP DATABASE IF EXISTS Discoteca;
CREATE DATABASE Discoteca;
USE Discoteca;

# Criar tabelas
DROP TABLE IF EXISTS Artistas;
CREATE TABLE Artistas (
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL UNIQUE,
    Formacao enum('Solo','Grupo'),
    PRIMARY KEY (Codigo) 
# Se o PRIMARY KEY der erro, 
# usar o comando abaixo, fora do CREATE TABLE
);
### ALTER TABLE Artistas ADD PRIMARY KEY (Codigo); 

DROP TABLE IF EXISTS Musicas;
CREATE TABLE Musicas (
    Codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Artista INT UNSIGNED NOT NULL,
    PRIMARY KEY (Codigo),
    FOREIGN KEY (Artista) REFERENCES Artistas(Codigo) 
# Se o FOREING KEY der erro, 
# usar o comando abaixo, fora do CREATE TABLE
);
### ALTER TABLE Musicas ADD FOREIGN KEY (Artista) REFERENCES Artistas(Codigo);

# Inserir artistas
INSERT INTO Artistas (Nome,Formacao) VALUES
('Legiao Urbana', 'Grupo'),
('Renato Russo', 'Solo'),
('Capital Inicial', 'Grupo'),
('Barao Vermelho', 'Grupo'),
('Cazuza', 'Solo');

# Criar PROCEDURE que encontra o codigo do artista
DROP PROCEDURE IF EXISTS CODIGOARTISTA;
DELIMITER //
CREATE PROCEDURE CODIGOARTISTA(
  IN NomeArtista VARCHAR(255),
  OUT CodigoArtista INT UNSIGNED)
BEGIN
  SELECT Codigo INTO CodigoArtista FROM Artistas 
  WHERE Nome=NomeArtista LIMIT 1;
END //
DELIMITER ;

## Inserir musicas ##
#Encontrar codigo do artista 
CALL CodigoArtista('Legiao Urbana',@CodigoArtista);

#Inserir musica usando o codigo encontrado
INSERT INTO Musicas (Nome,Artista) 
VALUES 
    ('Sera',@CodigoArtista);

#O Codigo nao desaparece depois do INSERT
INSERT INTO Musicas (Nome,Artista) 
VALUES 
    ('Pais e Filhos',@CodigoArtista),
    ('Faroeste Caboclo',@CodigoArtista),
    ('Tempo Perdido',@CodigoArtista),
    ('Indios',@CodigoArtista);

#Encontrar novo codigo para outro artista
CALL CodigoArtista('Cazuza',@CodigoArtista);

#Inserir musicas com o novo codigo
INSERT INTO Musicas (Nome,Artista) VALUES 
    ('Exagerado',@CodigoArtista),
    ('Faz parte do meu show',@CodigoArtista);

# Criar VIEW para Acervo
CREATE VIEW Acervo AS 
SELECT Musicas.codigo AS CodigoMusica, Musicas.Nome AS Musica, 
        Artistas.Nome AS Artista 
FROM Musicas INNER JOIN Artistas 
ON Musicas.Artista = Artistas.Codigo 
ORDER BY Artistas.Nome;

#Usar a VIEW ao inves do SELECT enoooorme
SELECT * FROM Acervo;
