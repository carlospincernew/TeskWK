CREATE SCHEMA dbtestwk ;

CREATE TABLE dbtestwk.produtos (
  id INT NOT NULL,
  descricao VARCHAR(60) NULL,
  preco_venda DECIMAL(18,2) NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE,
  INDEX descricao (descricao ASC) VISIBLE);
  
CREATE TABLE dbtestwk.clientes (
  id INT NOT NULL,
  nome VARCHAR(50) NULL,
  cidade VARCHAR(50) NULL,
  uf CHAR(2) NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE,
  INDEX nome (nome ASC) VISIBLE);
  
CREATE TABLE dbtestwk.pedidos (
  id INT NOT NULL,
  data_emissao DATE NULL,
  id_cliente INT NULL,
  valor_total DECIMAL(18,2) NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX id_pedido_unique (id ASC) VISIBLE,
  INDEX fk_pedido_id_cliente_idx (id_cliente ASC) VISIBLE,
  CONSTRAINT fk_pedido_id_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES dbtestwk.clientes (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE);
  
CREATE TABLE dbtestwk.pedidos_produtos (
  id INT NOT NULL AUTO_INCREMENT,
  id_produto INT NOT NULL,
  id_pedido INT NOT NULL,
  quantidade INT NULL,
  valor_unitario DECIMAL(18,2) NULL,
  valor_total DECIMAL(18,2) NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX id_UNIQUE (id ASC) VISIBLE,
  INDEX fk_pedidos_produtos_produto_idx (id_produto ASC) VISIBLE,
  INDEX fk_pedidos_produtos_pedido_idx (id_pedido ASC) VISIBLE,
  CONSTRAINT fk_pedidos_produtos_produto
    FOREIGN KEY (id_produto)
    REFERENCES dbtestwk.produtos (id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT fk_pedidos_produtos_pedido
    FOREIGN KEY (id_pedido)
    REFERENCES dbtestwk.pedidos (id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);