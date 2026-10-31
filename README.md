# OptiStock ? Banco de Dados

O banco usa PostgreSQL 18, com acesso pelo Entity Framework Core 10.0.12 e Npgsql 10.0.3. O site e o aplicativo compartilham os dados por meio do back-end ASP.NET Core.

As tabelas, colunas, ?ndices, restri??es, sequ?ncias, views, fun??es e triggers da aplica??o t?m nomes reais em portugu?s. As classes C# continuam com seus nomes atuais e usam mapeamentos expl?citos no Site_Pim.

- [Diagrama do banco](docs/esquema-visual.md)
- [Dicion?rio dos nomes e instru??es de atualiza??o](docs/nomes-banco.md)
- [Todos os CREATEs do esquema atual](docs/esquema-atual.sql) ? refer?ncia exportada de uma instala??o limpa; use as migrations para instalar.
- [SQL da renomea??o](migrations/20261031222433_TraduzirNomesBanco.sql)
- [Defini??es das views, fun??es e triggers](scripts/objetos-portugues.sql)

## Estrutura

| Tabela | Conte?do |
|---|---|
| `categorias` | Categorias das pe?as |
| `fornecedores` | Dados dos fornecedores |
| `pecas` | Cadastro, pre?o, saldo, estoque m?nimo e localiza??o |
| `movimentacoes_estoque` | Entradas, sa?das, saldos e usu?rio respons?vel |
| `comunicados` | Comunicados internos |
| `usuarios` | Usu?rios e dados de autentica??o |
| `perfis` e `usuarios_perfis` | Perfis e v?nculos dos usu?rios |
| `permissoes_usuarios` e `permissoes_perfis` | Permiss?es adicionais |
| `logins_usuarios` e `tokens_usuarios` | Autentica??o externa e tokens |

## Instala??o

Execute os comandos na pasta DataBase_Pim, com o cliente `psql` dispon?vel no PATH, ou execute os arquivos SQL pelo pgAdmin. O script de cria??o do banco usa comandos interativos exclusivos do psql.

```powershell
psql -h localhost -p 5432 -U postgres -d postgres -f scripts/create-database.sql
psql -h localhost -p 5432 -U optistock_user -d optistock -v ON_ERROR_STOP=1 -f migrations/optistock-idempotent.sql
```

O primeiro comando solicita usu?rio, senha e nome do banco. Substitua os nomes no segundo comando pelos escolhidos. O consolidado aplica apenas as migrations pendentes, incluindo a renomea??o para portugu?s.

Para atualizar um banco existente, pare o site, aplique somente o segundo comando e inicie a vers?o atualizada do Site_Pim. A vers?o atualizada tamb?m pode aplicar as migrations ao iniciar. N?o use a vers?o antiga do site com o esquema novo. Fa?a backup antes de atualizar dados importantes.

N?o execute os scripts individuais depois do consolidado. Para uma instala??o manual por etapas, a ordem ? InitialCreate, AddAnnouncements, AddStockDatabaseObjects e TraduzirNomesBanco. As migrations antigas mant?m seus nomes originais porque s?o hist?rico de vers?es j? aplicadas.

## Consultas

```sql
SELECT * FROM pecas ORDER BY nome;
SELECT * FROM visao_geral_estoque ORDER BY nome;
SELECT * FROM movimentacoes_estoque ORDER BY ocorrido_em_utc DESC LIMIT 50;
SELECT * FROM movimentacoes_diarias ORDER BY data_movimentacao_utc DESC;
SELECT * FROM fn_resumo_estoque();
SELECT * FROM fn_totais_movimentacoes(
    '2026-10-01 00:00:00+00', '2026-11-01 00:00:00+00'
);
```

## Regras e automa??es

O banco impede saldo, estoque m?nimo ou pre?o negativos. Movimenta??es exigem quantidade positiva, tipo Entry ou Exit e saldo posterior coerente com a opera??o. O hist?rico n?o pode ser editado nem apagado; corre??es devem ser novas movimenta??es.

- `visao_geral_estoque`: pe?as com categoria, fornecedor, situa??o e valor do estoque.
- `movimentacoes_diarias`: entradas e sa?das agrupadas pelo dia UTC.
- `fn_resumo_estoque()`: pe?as ativas, unidades, estoque baixo/zerado e valor total.
- `fn_totais_movimentacoes(p_inicio, p_fim)`: totais no per?odo [in?cio, fim).
- `trg_pecas_atualizar_data`: atualiza `atualizado_em_utc` ao alterar uma pe?a.
- `trg_movimentacoes_proteger_historico`: bloqueia UPDATE e DELETE no hist?rico.

A l?gica de cadastro e a atualiza??o do saldo ficam na aplica??o, dentro de suas transa??es. Os triggers n?o atualizam o saldo automaticamente.

## Dados de demonstra??o

Ap?s criar um usu?rio ativo pela aplica??o:

```powershell
psql -h localhost -U optistock_user -d optistock -v ON_ERROR_STOP=1 -f scripts/seed-demo.sql
```

A carga usa os nomes reais em portugu?s e registros fict?cios identificados como demonstra??o.

## Migrations e c?digo de refer?ncia

O projeto Site_Pim ? a fonte can?nica das migrations e do modelo. As c?pias em `migrations/ef-core-source` s?o apenas refer?ncia e precisam continuar sincronizadas com o site. `scripts/nomes-portugues.json` registra o dicion?rio da tradu??o.

A tabela t?cnica `__EFMigrationsHistory` e suas colunas mant?m o padr?o do EF Core para reconhecer as vers?es j? aplicadas. Os cat?logos internos do PostgreSQL tamb?m mant?m seus nomes de sistema. Entry e Exit s?o valores do enum da aplica??o, n?o nomes de tabelas ou colunas.

`scripts/views-portugues.sql` foi substitu?do: os nomes em portugu?s agora identificam tabelas reais. A migration remove as antigas views auxiliares para liberar esses nomes.

N?o versione senhas, tokens, backups ou dados pessoais. O administrador e os perfis da aplica??o s?o preparados pelo IdentitySeeder do site.
