# OptiStock — Banco de Dados

## 1. Identificação

**Projeto:** OptiStock — Sistema de gerenciamento de estoque  
**Componente:** banco relacional, esquema, migrações e rotina inicial  
**SGBD:** PostgreSQL 18  
**Acesso da aplicação:** Entity Framework Core 10.0.12 com Npgsql 10.0.3.

## 2. Apresentação

Esta pasta reúne os arquivos relacionados ao banco do OptiStock, desde a criação do usuário e do banco até as migrações, regras de integridade, funções, views e triggers. O site e o aplicativo compartilham este mesmo banco por meio do back-end ASP.NET Core.

As alterações estruturais oficiais são controladas pelas migrations do EF Core no projeto `Site_Pim`. Os scripts SQL exportados aqui reproduzem essas migrations para administração e implantação do PostgreSQL sem executar a interface web.

## 3. Conteúdo do repositório

- `scripts/create-database.sql`: cria interativamente o usuário da aplicação e o banco.
- `migrations/20261010221035_InitialCreate.sql`: esquema inicial e tabelas do Identity, categorias, fornecedores, peças e movimentações.
- `migrations/20261010222023_AddAnnouncements.sql`: tabela e índices de comunicados internos.
- `migrations/20261030144830_AddStockDatabaseObjects.sql`: condições adicionais, funções, views e triggers.
- `migrations/optistock-idempotent.sql`: instalação/atualização completa; aplica somente as migrações ainda pendentes.
- `migrations/ef-core-source/`: cópias para consulta das migrations, snapshot, DbContext, entidades e rotina de criação dos perfis/administrador.
- `.gitignore`: evita incluir segredos, logs e backups no repositório.

As cópias em `ef-core-source` servem como referência. A fonte canônica das migrations e do modelo continua no projeto `Site_Pim`; mantenha os arquivos deste repositório sincronizados quando o modelo mudar.

## 4. Modelo e regras de integridade

O esquema contém usuários e papéis do ASP.NET Core Identity, categorias, fornecedores, peças, movimentações de estoque e comunicados. As migrations definem chaves estrangeiras, índices únicos e demais relações.

As regras de estoque no banco incluem:

- quantidade, estoque mínimo e preço não negativos;
- quantidade movimentada maior que zero e saldos anterior/posterior não negativos;
- tipo de movimento restrito a `Entry` ou `Exit`;
- saldo posterior igual ao saldo anterior mais a entrada ou menos a saída;
- histórico de movimentações imutável: correções devem ser lançadas como nova movimentação;
- atualização automática de `Parts.UpdatedAtUtc` em alterações de peça.

A aplicação continua responsável por calcular e atualizar o saldo dentro da transação de negócio. Os triggers validam e protegem a integridade; não duplicam a atualização do saldo.

## 5. Funções, views e triggers

### Funções

- `fn_optistock_stock_summary()`: devolve total de peças ativas, unidades, itens em estoque baixo/zerado e valor estimado.
- `fn_optistock_movement_totals(p_from, p_until)`: agrega entradas e saídas no período `[início, fim)` e rejeita datas nulas ou invertidas.
- `fn_optistock_set_updated_at()`: atualiza o instante de alteração de uma peça.
- `fn_optistock_prevent_movement_change()`: impede editar ou apagar o histórico de movimentações.

### Views

- `vw_stock_overview`: consulta peça, categoria, fornecedor, saldo, localização, situação e valor do saldo.
- `vw_stock_movements_daily`: totaliza quantidade e número de entradas/saídas por dia UTC.

### Triggers

- `trg_parts_set_updated_at`: mantém `UpdatedAtUtc` atualizado em alterações de peças.
- `trg_stockmovements_immutable`: bloqueia `UPDATE` e `DELETE` em movimentações históricas.

### Exemplos de consulta

~~~sql
SELECT * FROM vw_stock_overview ORDER BY name;
SELECT * FROM vw_stock_movements_daily ORDER BY movement_date_utc DESC;
SELECT * FROM fn_optistock_stock_summary();
SELECT * FROM fn_optistock_movement_totals(
    '2026-10-01 00:00:00+00',
    '2026-11-01 00:00:00+00'
);
~~~

## 6. Requisitos

- PostgreSQL 18 e cliente de linha de comando `psql`.
- Uma conta administrativa PostgreSQL para preparar o banco.
- A aplicação ASP.NET Core precisa receber uma connection string apontando para o usuário e o banco criados.
