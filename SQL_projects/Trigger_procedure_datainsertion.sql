CREATE TRIGGER UpdateDuracao
ON dbo.CursosDisciplinas
FOR INSERT, UPDATE, DELETE
AS 
BEGIN 
	DECLARE @Action as char(1);
   	SET @Action = (CASE WHEN EXISTS(SELECT * FROM INSERTED)
                         AND EXISTS(SELECT * FROM DELETED)
                        THEN 'U'  -- Set Action to Updated.
                        WHEN EXISTS(SELECT * FROM INSERTED)
                        THEN 'I'  -- Set Action to Insert.
                        WHEN EXISTS(SELECT * FROM DELETED)
                        THEN 'D'  -- Set Action to Deleted.
                        ELSE NULL -- Skip. It may have been a "failed delete".   
                    END)
                    
	DECLARE 
	@idCurso int, 
	@idDisciplina int,
	@CargaHoraria int,
	@idCurso2 int,
	@idDisciplina2 int,
	@CargaHoraria2 int
	
	IF @Action = 'I'
		BEGIN
			SELECT @idCurso = idCurso, @idDisciplina = idDisciplina FROM  INSERTED
			SELECT @CargaHoraria = CargaHoraria FROM dbo.Disciplinas 
				WHERE idDisciplina = @idDisciplina 
			UPDATE dbo.Cursos SET DuracaoTotal = DuracaoTotal + @CargaHoraria
				WHERE idCurso = @idCurso
		END
	ELSE IF @Action = 'D'
		BEGIN
			SELECT @idCurso = idCurso, @idDisciplina = idDisciplina FROM DELETED
			SELECT @CargaHoraria = CargaHoraria FROM dbo.Disciplinas 
				WHERE idDisciplina = @idDisciplina 
			UPDATE dbo.Cursos SET DuracaoTotal = DuracaoTotal - @CargaHoraria
				WHERE idCurso = @idCurso
		END
	ELSE IF @Action = 'U'
		BEGIN
			SELECT @idCurso = idCurso, @idDisciplina = idDisciplina FROM INSERTED
			SELECT @idCurso2 = idCurso, @idDisciplina2 = idDisciplina FROM DELETED
			SELECT @CargaHoraria = CargaHoraria FROM dbo.Disciplinas 
				WHERE idDisciplina = @idDisciplina 
			SELECT @CargaHoraria2 = CargaHoraria FROM dbo.Disciplinas 
				WHERE idDisciplina = @idDisciplina2 
			UPDATE dbo.Cursos SET DuracaoTotal = DuracaoTotal + @CargaHoraria
				WHERE idCurso = @idCurso
			UPDATE dbo.Cursos SET DuracaoTotal = DuracaoTotal - @CargaHoraria2
				WHERE idCurso = @idCurso2
		END
END 
GO

CREATE VIEW ViewID AS
SELECT Matriculas.idAluno,
	   Matriculas.idMatricula,
	   Turmas.idTurma,
	   Cursos.idCurso,
	   CursosDisciplinas.idDisciplina,
	   Turmas.idEmpresa,
	   Turmas.NomeProcessoSeletivo,
	   Cursos.NomeCurso
FROM Matriculas
LEFT JOIN Turmas
ON Matriculas.idTurma = Turmas.idTurma
LEFT JOIN Cursos
ON Cursos.idCurso = Turmas.idCurso
LEFT JOIN CursosDisciplinas
ON Cursos.idCurso=CursosDisciplinas.idCurso;
GO

CREATE VIEW ViewDuracaoCurso AS
SELECT Cursos.NomeCurso,
      	 SUM(Disciplinas.CargaHoraria) AS DuracaoTotal
FROM Cursos
INNER JOIN CursosDisciplinas ON Cursos.idCurso = CursosDisciplinas.idCurso
INNER JOIN Disciplinas ON Disciplinas.idDisciplina = CursosDisciplinas.idDisciplina
GROUP BY Cursos.NomeCurso;
GO

CREATE PROCEDURE InserirNotas
@idMatricula int,
@idDisciplina int,
@Nota float
AS
BEGIN
	IF @idMatricula NOT IN (SELECT idMatricula FROM ViewID WHERE idDisciplina = @idDisciplina)
		BEGIN
			RAISERROR('Disciplina %i não pertence à Matrícula %i',16,0,@idDisciplina, @idMatricula)
		END
	ELSE
		INSERT INTO Notas (idMatricula,idDisciplina,Nota)
		VALUES (@idMatricula,@idDisciplina,@Nota)
	
END 
GO


INSERT INTO db_lufalufa.dbo.EmpresasParceiras
(NomeEmpresa, CNPJ, Endereco, AreaAtuacao)
VALUES('Empresa1', '58160789000128', 'Av Paulista', 'Finanças'), 
('Empresa2', '60701190000106', 'Rua Consolação', 'Finanças'), 
('Empresa3', '76535764000143', 'Rua dos Telefones', 'Telecomunicações'), 
('Empresa4', '09346601000125', 'Rua das Acoes', 'Finanças'), 
('Empresa5', '61590410000124', 'Rua da Saude', 'Saude'), 
('Empresa6', '06990590000123', 'Rua do Buscador', 'Tecnologia');

INSERT INTO db_lufalufa.dbo.Professores
(Nome, NumDocumento, Email, AreaAtuacao, DataInicio, Senioridade, Salario)
VALUES('Brian', '963595317541', 'brian@gmail.com', 'Estudante', '2021-04-02', 'Junior', 1700),
('Rafa', '735454338714', 'rafael@gmail.com', 'Professor', '2020-08-21', 'Pleno', 2100),
('Livia', '674595141657', 'livia@gmail.com', 'Banco de Dados', '2019-01-01', 'Senior', 2400),
('Romero', '684083121474', 'romero@gmail.com', 'Cientista de Dados', '2022-04-03', 'Pleno', 2000),
('Bruna', '256579287646', 'bruna@gmail.com', 'DEVOPS', '2022-06-03', 'Pleno', 2050);

INSERT INTO db_lufalufa.dbo.Cursos
(idCoordenador, DuracaoTotal, Preco, NomeCurso)
VALUES(5, 0, 14000, 'DEVOPS'), 
(2, 0, 15000, 'Data Science'), 
(1, 0, 21000, 'Full Stack');


INSERT INTO db_lufalufa.dbo.Disciplinas
(idProfessor, idProfessorAux, NomeDisciplina, CargaHoraria, NotaAprovacao)
VALUES(5, 1, 'Python', 20, 5),
(3, 4, 'JavaScript', 24, 5),
(2, 5, 'CSS', 18, 5),
(3, 2, 'MSSQL',20, 5),
(1, 5, 'Estatistica',22, 5),
(4, 2, 'Machine Learning', 18, 5),
(2, 5, 'Docker', 20, 5),
(3, 1, 'Kubernetes', 26, 5),
(5, 4, 'AWS', 16, 5);

INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(2, 1);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(3, 1);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(3, 2);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(1, 2);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(3, 3);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(2, 4);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(1, 4);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(2, 5);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(2, 6);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(3, 6);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(1, 7);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(3, 7);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(1, 8);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(2, 8);
INSERT INTO db_lufalufa.dbo.CursosDisciplinas
(idCurso, idDisciplina)
VALUES(1, 9);

INSERT INTO db_lufalufa.dbo.Turmas
(idCurso, idEmpresa, NomeProcessoSeletivo, Vagas, DataInicio, DataFim)
VALUES (2, 1, 'TopCoders', 25, '2022-05-12', '2022-11-23'),
	(1, 1, 'TopCoders', 50, '2022-05-12', '2022-11-23'),
	(1, 2, 'Bootcamp Itau Devs', 40, '2022-05-16', '2023-01-25'),
	(1, 3, 'Oi Devs', 15, '2022-09-21', '2023-02-25'),
	(1, 5, 'Sirio Libanes Tech', 10, '2022-08-24', '2023-02-08'),
	(3, 4, 'Programa <Dev>a', 20, '2022-09-14', '2023-03-14'),
	(1, 4, 'Programa <Dev>a', 20, '2022-09-14', '2023-03-14'),
	(2, 6, 'Prep Tech _afro', 30, '2022-08-01', '2022-12-12');

INSERT INTO db_lufalufa.dbo.Alunos
(Nome, Email, NumDocumento, DataNascimento, Telefone, Endereco, Cidade)
VALUES('Gustavo P', 'gustavo@gmail.com', '12345678900', '1990-08-01', '16998124567', 'Rua Sem Nome, 456', 'Sao Paulo'),
('Bruno B', 'brunobe@gmail.com', '46327939066', '1998-01-07', '11869915959', 'Avenida Jorge, 654', 'Santos'),
('Rodrigo S', 'rodrigo@gmail.com', '25138816055', '1997-10-18', '8932894954', 'Rua Leste, 69', 'Recife'),
('Fernanda D', 'fernanda@gmail.com', '20604797036', '1995-02-05', '6238536862', 'Rua Agile, 87', 'Sao Paulo'),
('Daniel G', 'daniel@gmail.com', '66785791006', '1996-11-03', '9222880881', 'Rua Ferrari, 645', 'Sao Paulo'),
('Guilherme F', 'guilherme@gmail.com', '21158345003', '1995-12-25', '7523344423', 'Avenida Golf, 87', 'Campinas'),
('Joao R', 'joao@gmail.com', '21471223000', '1997-11-01', '9522254771', 'Rua Honda, 64', 'Recife'),
('Bruno S', 'bruno@gmail.com', '40445343060', '1990-02-22', '9635805160', 'Rua Lambo, 32', 'Salvador'),
('Guilherme H', 'guilhermeh@gmail.com', '14104148091', '1989-03-26', '9229334466', 'Rua R35, 645', 'Orlando'),
('Tania R', 'tania@gmail.com', '85305187052', '1986-04-25', '7735427288', 'Avenida Silvia, 678', 'Barueri'),
('Rodolfo J', 'rodolfo@gmail.com', '56526770070', '1985-05-24', '8421570788', 'Rua Lancer, 543', 'Osasco'),
('Brenda T', 'brenda@gmail.com', '22162850052', '1981-06-29', '9425224813', 'Rua Evo, 786', 'Rio de Janeiro'),
('Carol E', 'carol@gmail.com', '48813002025', '1998-05-12', '9622766494', 'Rua Fiat, 88', 'Sao Paulo'),
('Renato J', 'renato@gmail.com', '90689598084', '1998-08-08', '9622665102', 'Avenida Audi, 687', 'Porto Alegre'),
('Luiz G', 'luiz@gmail.com', '39553954057', '1997-09-25', '7935671335', 'Rua Sandero, 645', 'Sao Paulo'),
('Gabriel I', 'gabriel@gmail.com', '54939601099', '1996-08-12', '1538173994', 'Rua Nissan, 687', 'Sao Paulo'),
('Lucas U', 'lucas@gmail.com', '77256542089', '1995-07-11', '672693-8347', 'Avenida GTR, 845', 'Porto Alegre'),
('Ariel T', 'ariel@gmail.com', '90811145069', '1998-02-05', '7736177334', 'Rua Senna, 68', 'Rio de Janeiro'),
('Jessica L', 'jessica@gmail.com', '37172177045', '1999-01-03', '8536845927', 'Rua Inter, 356', 'Rio de Janeiro'),
('Joyce Q', 'joyce@gmail.com', '74238597028', '1998-03-22', '5429599111', 'Avenida Breno, 154', 'Sao Paulo');

INSERT INTO db_lufalufa.dbo.Matriculas
(idAluno, idTurma)
VALUES (1, 1),
(2, 2),
(3, 2),
(4, 3),
(5, 1),
(6, 3),
(7, 4),
(8, 3),
(9, 2),
(10, 5),
(11, 5),
(12, 6),
(13, 2),
(14, 3),
(15, 4),
(16, 3),
(17, 2),
(18, 1),
(19, 3),
(20, 1);

INSERT INTO db_lufalufa.dbo.Notas
(idMatricula, idDisciplina, Nota)
VALUES (1,1,7.8),
(1, 4, 6.7), 
(1, 5, 9.2), 
(1, 6, 8.0), 
(2, 7, 9.4), 
(13, 8, 7.1),
(2, 9, 7.7), 
(3, 7, 6.5), 
(15, 8, 8.3), 
(4, 7, 6.2), 
(6, 8, 6.6), 
(11, 9, 9.7), 
(12, 9, 5.9), 
(5, 1, 8.8), 
(5, 4, 7.7), 
(8, 9, 7.8), 
(9, 9, 7.9), 
(14, 7, 9.7), 
(16, 9, 10.0), 
(19, 8, 6.2);

EXECUTE InserirNotas
@idMatricula = 20,
@idDisciplina = 4,
@Nota = 5.4
