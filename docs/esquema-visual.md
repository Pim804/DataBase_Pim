# Esquema visual do banco OptiStock

Este diagrama apresenta primeiro o nome intuitivo em português e, entre aspas, o nome físico usado pelo PostgreSQL. Os nomes físicos permanecem em inglês para continuar compatíveis com o site, a API e as migrations existentes.

```mermaid
erDiagram
    CATEGORIA ||--o{ PECA : "classifica"
    FORNECEDOR o|--o{ PECA : "fornece"
    PECA ||--o{ MOVIMENTACAO : "possui historico"
    USUARIO ||--o{ MOVIMENTACAO : "registra"
    USUARIO ||--o{ COMUNICADO : "publica"
    USUARIO ||--o{ USUARIO_PERFIL : "recebe perfil"
    PERFIL ||--o{ USUARIO_PERFIL : "e atribuido"

    CATEGORIA {
        int id PK "Categories.Id"
        string nome UK "Categories.Name"
        string descricao "Categories.Description"
        boolean ativo "Categories.IsActive"
        timestamptz criado_em "Categories.CreatedAtUtc"
    }

    FORNECEDOR {
        int id PK "Suppliers.Id"
        string nome "Suppliers.Name"
        string documento_fiscal UK "Suppliers.TaxId"
        string telefone "Suppliers.Phone"
        string email "Suppliers.Email"
        string endereco "Suppliers.Address"
        boolean ativo "Suppliers.IsActive"
    }

    PECA {
        int id PK "Parts.Id"
        string codigo UK "Parts.Code"
        string nome "Parts.Name"
        string descricao "Parts.Description"
        int categoria_id FK "Parts.CategoryId"
        int fornecedor_id FK "Parts.SupplierId opcional"
        int quantidade "Parts.StockQuantity"
        int estoque_minimo "Parts.MinimumStock"
        numeric preco_unitario "Parts.UnitPrice"
        string localizacao "Parts.WarehouseLocation"
        boolean ativo "Parts.IsActive"
        timestamptz criado_em "Parts.CreatedAtUtc"
        timestamptz atualizado_em "Parts.UpdatedAtUtc"
        bigint versao "Parts.Version"
    }

    MOVIMENTACAO {
        bigint id PK "StockMovements.Id"
        int peca_id FK "StockMovements.PartId"
        string tipo "StockMovements.Type Entry ou Exit"
        int quantidade "StockMovements.Quantity"
        int saldo_anterior "StockMovements.PreviousBalance"
        int saldo_posterior "StockMovements.NewBalance"
        string observacao "StockMovements.Notes"
        timestamptz ocorrido_em "StockMovements.OccurredAtUtc"
        uuid usuario_id FK "StockMovements.UserId"
    }

    COMUNICADO {
        int id PK "Announcements.Id"
        string titulo "Announcements.Title"
        string conteudo "Announcements.Content"
        timestamptz criado_em "Announcements.CreatedAtUtc"
        timestamptz publicado_em "Announcements.PublishedAtUtc"
        boolean publicado "Announcements.IsPublished"
        boolean arquivado "Announcements.IsArchived"
        uuid autor_id FK "Announcements.AuthorId"
    }

    USUARIO {
        uuid id PK "AspNetUsers.Id"
        string nome "AspNetUsers.DisplayName"
        string email UK "AspNetUsers.Email"
        boolean ativo "AspNetUsers.IsActive"
        timestamptz criado_em "AspNetUsers.CreatedAtUtc"
    }

    PERFIL {
        uuid id PK "AspNetRoles.Id"
        string nome UK "AspNetRoles.Name"
    }

    USUARIO_PERFIL {
        uuid usuario_id PK_FK "AspNetUserRoles.UserId"
        uuid perfil_id PK_FK "AspNetUserRoles.RoleId"
    }
```

## Como ler as ligações

- `||` significa exatamente um registro.
- `o{` significa zero ou muitos registros.
- `o|` significa zero ou um registro.
- `PK` é a chave primária; `FK` aponta para outra tabela; `UK` indica valor único.

Exemplos: cada peça tem uma categoria; uma categoria pode classificar várias peças. Uma peça pode ter zero ou um fornecedor, e um fornecedor pode fornecer várias peças. Cada movimentação se refere a uma peça e a um usuário responsável.

## Tabelas auxiliares do login

O ASP.NET Identity também mantém `AspNetUserClaims`, `AspNetRoleClaims`, `AspNetUserLogins` e `AspNetUserTokens`. Elas guardam permissões adicionais, provedores de login e tokens de autenticação. São tabelas técnicas do sistema de login e não fazem parte do fluxo normal de cadastro de estoque.

## Objetos automáticos do PostgreSQL

Além das tabelas, a migration `20261030144830_AddStockDatabaseObjects` cria as views `vw_stock_overview` e `vw_stock_movements_daily`, as funções `fn_optistock_stock_summary` e `fn_optistock_movement_totals`, as funções internas dos triggers e os triggers `trg_parts_set_updated_at` e `trg_stockmovements_immutable`.

As condições impedem saldo, quantidade ou preço negativos; restringem o tipo de movimentação; e exigem que o saldo posterior corresponda à operação registrada.
