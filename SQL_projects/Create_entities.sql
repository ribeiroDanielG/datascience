CREATE TABLE Alunos(
	idAluno int IDENTITY(1,1) PRIMARY KEY,
	Nome varchar(80) NOT NULL,
	Email varchar(50) NOT NULL,
	NumDocumento char(12) NOT NULL,
	DataNascimento date NOT NULL,
	Telefone char(11) NOT NULL,
	Endereco varchar(80),
	Cidade varchar(50)
);

CREATE TABLE EmpresasParceiras(
	idEmpresa int IDENTITY(1,1) PRIMARY KEY,
	NomeEmpresa varchar(80) NOT NULL,
	CNPJ char(14) NOT NULL,
	Endereco varchar(80),
	AreaAtuacao varchar(80) NOT NULL
);

CREATE TABLE Professores(
	idProfessor int IDENTITY(1,1) PRIMARY KEY,
	Nome varchar(80) NOT NULL,
	NumDocumento CHAR(12) NOT NULL,
	Email varchar(80) NOT NULL,
	AreaAtuacao varchar(80),
	DataInicio date NOT NULL,
	Senioridade varchar(80) NOT NULL,
	Salario float NOT NULL
);

CREATE TABLE Disciplinas(
	idDisciplina int IDENTITY(1,1) PRIMARY KEY,
	idProfessor int NOT NULL FOREIGN KEY REFERENCES Professores(idProfessor),
	idProfessorAux int NOT NULL FOREIGN KEY REFERENCES Professores(idProfessor),
	NomeDisciplina varchar(80) NOT NULL,
	CargaHoraria int NOT NULL,
	NotaAprovacao float NOT NULL,
	MateriaisComplementares varchar(80)
);

CREATE TABLE Cursos(
	idCurso int IDENTITY(1,1)  PRIMARY KEY,
	idCoordenador int NOT NULL FOREIGN KEY REFERENCES Professores(idProfessor),
	DuracaoTotal int NOT NULL,
	Preco float NOT NULL,
	NomeCurso varchar(80) NOT NULL
);

CREATE TABLE CursosDisciplinas(
	idCurso int NOT NULL FOREIGN KEY REFERENCES Cursos(idCurso),
	idDisciplina int NOT NULL FOREIGN KEY REFERENCES Disciplinas(idDisciplina)
);

CREATE TABLE Turmas(
	idTurma int IDENTITY(1,1)  PRIMARY KEY,
	idCurso int NOT NULL FOREIGN KEY REFERENCES Cursos(idCurso),
	idEmpresa int NOT NULL FOREIGN KEY REFERENCES EmpresasParceiras(idEmpresa),
	NomeProcessoSeletivo varchar(80) NOT NULL,
	Vagas int NOT NULL,
	DataInicio date NOT NULL,
	DataFim date
);

CREATE TABLE Matriculas(
	idMatricula int IDENTITY(1,1) PRIMARY KEY,
	idAluno int NOT NULL FOREIGN KEY REFERENCES Alunos(idAluno),
	idTurma int NOT NULL FOREIGN KEY REFERENCES Turmas(idTurma)
);

CREATE TABLE Notas(
	idNotas int IDENTITY(1,1) PRIMARY KEY,
	idMatricula int NOT NULL FOREIGN KEY REFERENCES Matriculas(idMatricula),
	idDisciplina int NOT NULL FOREIGN KEY REFERENCES Disciplinas(idDisciplina),
	Nota float NOT NULL
);
