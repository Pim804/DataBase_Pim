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
        int id PK "categorias.id"
        string nome UK "categorias.nome"
        string descricao "categorias.descricao"
        boolean ativo "categorias.ativo"
        timestamptz criado_em "categorias.criado_em_utc"
    }

    FORNECEDOR {
        int id PK "fornecedores.id"
        string nome "fornecedores.nome"
        string documento_fiscal UK "fornecedores.documento_fiscal"
        string telefone "fornecedores.telefone"
        string email "fornecedores.email"
        string endereco "fornecedores.endereco"
        boolean ativo "fornecedores.ativo"
    }

    PECA {
        int id PK "pecas.id"
        string codigo UK "pecas.codigo"
        string nome "pecas.nome"
        string descricao "pecas.descricao"
        int categoria_id FK "pecas.categoria_id"
        int fornecedor_id FK "pecas.fornecedor_id opcional"
        int quantidade "pecas.quantidade_estoque"
        int estoque_minimo "pecas.estoque_minimo"
        numeric preco_unitario "pecas.preco_unitario"
        string localizacao "pecas.localizacao_deposito"
        boolean ativo "pecas.ativo"
        timestamptz criado_em "pecas.criado_em_utc"
        timestamptz atualizado_em "pecas.atualizado_em_utc"
        bigint versao "pecas.versao"
    }

    MOVIMENTACAO {
        bigint id PK "movimentacoes_estoque.id"
        int peca_id FK "movimentacoes_estoque.peca_id"
        string tipo "movimentacoes_estoque.tipo Entry ou Exit"
        int quantidade "movimentacoes_estoque.quantidade"
        int saldo_anterior "movimentacoes_estoque.saldo_anterior"
        int saldo_posterior "movimentacoes_estoque.saldo_posterior"
        string observacao "movimentacoes_estoque.observacao"
        timestamptz ocorrido_em "movimentacoes_estoque.ocorrido_em_utc"
        uuid usuario_id FK "movimentacoes_estoque.usuario_id"
    }

    COMUNICADO {
        int id PK "comunicados.id"
        string titulo "comunicados.titulo"
        string conteudo "comunicados.conteudo"
        timestamptz criado_em "comunicados.criado_em_utc"
        timestamptz publicado_em "comunicados.publicado_em_utc"
        boolean publicado "comunicados.publicado"
        boolean arquivado "comunicados.arquivado"
        uuid autor_id FK "comunicados.autor_id"
    }

    USUARIO {
        uuid id PK "usuarios.id"
        string nome "usuarios.nome_exibicao"
        string email "usuarios.email"
        boolean ativo "usuarios.ativo"
        timestamptz criado_em "usuarios.criado_em_utc"
    }

    PERFIL {
        uuid id PK "perfis.id"
        string nome UK "perfis.nome"
    }

    USUARIO_PERFIL {
        uuid usuario_id PK_FK "usuarios_perfis.usuario_id"
        uuid perfil_id PK_FK "usuarios_perfis.perfil_id"
    }
```

## Como ler as ligações

- `||` significa exatamente um registro.
- `o{` significa zero ou muitos registros.
- `o|` significa zero ou um registro.
- `PK` é a chave primária; `FK` aponta para outra tabela; `UK` indica valor único.

Exemplos: cada peça tem uma categoria; uma categoria pode classificar várias peças. Uma peça pode ter zero ou um fornecedor, e um fornecedor pode fornecer várias peças. Cada movimentação se refere a uma peça e a um usuário responsável.

## Tabelas auxiliares do login

O ASP.NET Identity também mantém `permissoes_usuarios`, `permissoes_perfis`, `logins_usuarios` e `tokens_usuarios`. Elas guardam permissões adicionais, provedores de login e tokens de autenticação. São tabelas técnicas do sistema de login e não fazem parte do fluxo normal de cadastro de estoque.

## Objetos automáticos do PostgreSQL

Além das tabelas, a migration `TraduzirNomesBanco` mant?m em portugu?s as views `visao_geral_estoque` e `movimentacoes_diarias`, as funções `fn_resumo_estoque` e `fn_totais_movimentacoes`, as funções internas dos triggers e os triggers `trg_pecas_atualizar_data` e `trg_movimentacoes_proteger_historico`.

As condições impedem saldo, quantidade ou preço negativos; restringem o tipo de movimentação; e exigem que o saldo posterior corresponda à operação registrada.
