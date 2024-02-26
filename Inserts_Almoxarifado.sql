use banco_almoxarifado
go


-- Inserindo dados na tabela Almoxarifados
INSERT INTO Almoxarifados (id_Almoxarifado, nome_Almoxarifado, localizacao, responsavel)
VALUES (1, 'Almoxarifado Central', 'Rua A, Nº 123', 'João Silva'),
       (2, 'Almoxarifado Filial', 'Avenida B, Nº 456', 'Maria Oliveira'),
       (3, 'Almoxarifado Regional', 'Praça C, Nº 789', 'Carlos Santos');

-- Inserindo dados na tabela Produtos
INSERT INTO Produtos (id_Produto, nome_Produto, descricao, unidade_Medida)
VALUES (1, 'Produto A', 'Descrição do Produto A', 'UN'),
       (2, 'Produto B', 'Descrição do Produto B', 'CX'),
       (3, 'Produto C', 'Descrição do Produto C', 'KG');

-- Inserindo dados na tabela Estoque
INSERT INTO Estoque (id_Estoque, id_Almoxarifado, id_Produto, quantidade, data_Atualizacao)
VALUES (1, 1, 1, 100, '2024-02-08'),
       (2, 1, 2, 50, '2024-02-07'),
       (3, 2, 1, 75, '2024-02-06'),
       (4, 2, 3, 30, '2024-02-05'),
       (5, 3, 2, 40, '2024-02-04');

-- Inserindo dados na tabela MovimentacaoEstoque
INSERT INTO MovimentacaoEstoque (id_movimentacao, id_Estoque, tipo_Movimentacao, quantidade, data_Movimentacao)
VALUES (1, 1, 'Entrada', 50, '2024-02-08'),
       (2, 2, 'Saida', 25, '2024-02-07'),
       (3, 3, 'Entrada', 30, '2024-02-06'),
       (4, 4, 'Saida', 10, '2024-02-05'),
       (5, 5, 'Entrada', 20, '2024-02-04');

-- Inserindo dados na tabela PedidosAbastecimento
INSERT INTO PedidosAbastecimento (id_Pedido, id_Almoxarifado, data_Pedido, status_Pedido)
VALUES (1, 1, '2024-02-08', 'Pendente'),
       (2, 2, '2024-02-07', 'Aprovado'),
       (3, 3, '2024-02-06', 'Pendente');

-- Inserindo dados na tabela ItensPedidoAbastecimento
INSERT INTO ItensPedidoAbastecimento (id_Pedido, id_Produto, quantidade_Requerida)
VALUES (1, 1, 30),
       (1, 2, 20),
       (2, 1, 50),
       (3, 3, 15);

-- Inserindo dados na tabela Requisicoes
INSERT INTO Requisicoes (id_Requisicao, id_origem_Almoxarifado, id_destino_Almoxarifado, data_Requisicao, status_Requisicao)
VALUES (1, 1, 2, '2024-02-08', 'Pendente'),
       (2, 2, 1, '2024-02-07', 'Aprovada'),
       (3, 3, 1, '2024-02-06', 'Pendente');

-- Inserindo dados na tabela ItensRequisicao
INSERT INTO ItensRequisicao (id_Requisicao, id_Produto, quantidade_Requerida, quantidade_Atendida)
VALUES (1, 1, 40, 40),
       (1, 2, 25, 25),
       (2, 1, 50, 50),
       (3, 3, 20, 20);

-- Inserindo dados na tabela Transferencias
INSERT INTO Transferencias (id_Transferencia, id_origem_Almoxarifado, id_destino_Almoxarifado, data_Transferencia, status_Transferencia)
VALUES (1, 1, 2, '2024-02-08', 'Pendente'),
       (2, 2, 1, '2024-02-07', 'Concluida'),
       (3, 3, 1, '2024-02-06', 'Pendente');

-- Inserindo dados na tabela ItensTransferencia
INSERT INTO ItensTransferencia (id_Transferencia, id_Produto, quantidade_Transferida)
VALUES (1, 1, 20),
       (1, 2, 10),
       (2, 1, 30),
       (3, 3, 15);

