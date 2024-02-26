CREATE DATABASE banco_almoxarifado
go

use banco_almoxarifado
go

-- Mapa de Estoque
-- Tabela de informações dos almoxarifados
CREATE TABLE Almoxarifados (
    id_Almoxarifado INT PRIMARY KEY,
    nome_Almoxarifado VARCHAR(50) NOT NULL,
    localizacao VARCHAR(100),
    responsavel VARCHAR(50)
);

-- Tabela de informações sobre os produtos em estoque
CREATE TABLE Produtos (
    id_Produto INT PRIMARY KEY,
    nome_Produto VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    unidade_Medida VARCHAR(20) NOT NULL
);

-- Tabela de informações sobre o estoque em cada almoxarifado
CREATE TABLE Estoque (
    id_Estoque INT PRIMARY KEY,
    id_Almoxarifado INT,
    id_Produto INT,
    quantidade INT,
    data_Atualizacao DATETIME,
    FOREIGN KEY (id_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado),
    FOREIGN KEY (id_Produto) REFERENCES Produtos(id_Produto)
);

-- Tabela para movimentações no estoque (entrada e saída de produtos)
CREATE TABLE MovimentacaoEstoque (
    id_movimentacao INT PRIMARY KEY,
    id_Estoque INT,
    tipo_Movimentacao VARCHAR(10) CHECK (tipo_Movimentacao IN ('Entrada', 'Saida')) NOT NULL,
    quantidade INT,
    data_Movimentacao DATETIME,
    FOREIGN KEY (id_Estoque) REFERENCES Estoque(id_Estoque)
);

-- Tabela para armazenar informações sobre pedidos de abastecimento
CREATE TABLE PedidosAbastecimento (
    id_Pedido INT PRIMARY KEY,
    id_Almoxarifado INT,
    data_Pedido DATETIME,
    status_Pedido VARCHAR(20) CHECK (status_Pedido IN ('Pendente', 'Aprovado', 'Rejeitado')) NOT NULL,
    FOREIGN KEY (id_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado)
);

-- Tabela para associar produtos aos pedidos de abastecimento
CREATE TABLE ItensPedidoAbastecimento (
    id_Pedido INT,
    id_Produto INT,
    quantidade_Requerida INT,
    PRIMARY KEY (id_Pedido, id_Produto),
    FOREIGN KEY (id_Pedido) REFERENCES PedidosAbastecimento(id_Pedido),
    FOREIGN KEY (id_Produto) REFERENCES Produtos(id_Produto)
);

-- Baixas Automáticas
-- Tabela de informações sobre requisições de produtos
CREATE TABLE Requisicoes (
    id_Requisicao INT PRIMARY KEY,
    id_origem_Almoxarifado INT,
    id_destino_Almoxarifado INT,
    data_Requisicao DATETIME,
    status_Requisicao VARCHAR(20) CHECK (status_Requisicao IN ('Pendente', 'Aprovada', 'Rejeitada', 'Atendida')) NOT NULL,
    FOREIGN KEY (id_origem_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado),
    FOREIGN KEY (id_destino_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado)
);

-- Tabela para associar produtos às requisições
CREATE TABLE ItensRequisicao (
    id_Requisicao INT,
    id_Produto INT,
    quantidade_Requerida INT,
    quantidade_Atendida INT,
    PRIMARY KEY (id_Requisicao, id_Produto),
    FOREIGN KEY (id_Requisicao) REFERENCES Requisicoes(id_Requisicao),
    FOREIGN KEY (id_Produto) REFERENCES Produtos(id_Produto)
);

--Transferência entre Almoxarifados
-- Tabela de informações sobre transferências entre almoxarifados
CREATE TABLE Transferencias (
    id_Transferencia INT PRIMARY KEY,
    id_origem_Almoxarifado INT,
    id_destino_Almoxarifado INT,
    data_Transferencia DATETIME,
    status_Transferencia VARCHAR(20) CHECK (status_Transferencia IN ('Pendente', 'Concluida', 'Cancelada')) NOT NULL,
    FOREIGN KEY (id_origem_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado),
    FOREIGN KEY (id_destino_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado)
);

-- Tabela para associar produtos às transferências
CREATE TABLE ItensTransferencia (
    id_Transferencia INT,
    id_Produto INT,
    quantidade_Transferida INT,
    PRIMARY KEY (id_Transferencia, id_Produto),
    FOREIGN KEY (id_Transferencia) REFERENCES Transferencias(id_Transferencia),
    FOREIGN KEY (id_Produto) REFERENCES Produtos(id_Produto)
);


-- Criar tabela BaixasAutomaticas se ela ainda não existir
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BaixasAutomaticas')
BEGIN
    CREATE TABLE BaixasAutomaticas (
        id_Baixa INT PRIMARY KEY IDENTITY,
        id_Almoxarifado INT,
        id_Produto INT,
        quantidadeBaixada INT,
        DataBaixa DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (id_Almoxarifado) REFERENCES Almoxarifados(id_Almoxarifado),
        FOREIGN KEY (id_Produto) REFERENCES Produtos(id_Produto)
    );
END;
GO

-- Trigger para realizar a baixa automática quando uma requisição é atendida
CREATE TRIGGER AtenderRequisicao
ON Requisicoes
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(status_Requisicao) AND (SELECT status_Requisicao FROM INSERTED) = 'Atendida')
    BEGIN
        INSERT INTO BaixasAutomaticas (id_Almoxarifado, id_Produto, quantidadeBaixada, DataBaixa)
        SELECT r.id_destino_Almoxarifado, ir.id_Produto, ir.quantidade_Requerida, GETDATE()
        FROM ItensRequisicao ir
        INNER JOIN Requisicoes r ON r.id_Requisicao = ir.id_Requisicao
        WHERE r.id_Requisicao = (SELECT id_Requisicao FROM INSERTED);
    END;
END;
GO

-- Trigger para realizar a atualização dos estoques ao concluir uma transferência
CREATE TRIGGER ConcluirTransferencia
ON Transferencias
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(status_Transferencia) AND (SELECT status_Transferencia FROM INSERTED) = 'Concluida')
    BEGIN
        -- Atualizar estoque do almoxarifado de origem (subtrair quantidade transferida)
        UPDATE Estoque
        SET quantidade = quantidade - it.quantidade_Transferida
        FROM ItensTransferencia it
        WHERE Estoque.id_Estoque = it.id_Transferencia
          AND Estoque.id_Produto = it.id_Produto
          AND Estoque.id_Almoxarifado = (SELECT id_origem_Almoxarifado FROM INSERTED);

        -- Atualizar estoque do almoxarifado de destino (adicionar quantidade transferida)
        INSERT INTO Estoque (id_Almoxarifado, id_Produto, quantidade, data_Atualizacao)
        SELECT (SELECT id_destino_Almoxarifado FROM INSERTED), it.id_Produto, it.quantidade_Transferida, GETDATE()
        FROM ItensTransferencia it
        WHERE it.id_Transferencia = (SELECT id_Transferencia FROM INSERTED);
    END;
END;
GO


