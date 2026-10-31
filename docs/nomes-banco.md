# Nomes reais em portugues

A migration `TraduzirNomesBanco` renomeia as tabelas e colunas existentes, preservando os registros. O `Site_Pim` recebe os mapeamentos correspondentes. Os nomes das classes C# e dos contratos da API continuam iguais.

## Tabelas

| Nome anterior | Nome atual |
|---|---|
| `AspNetRoles` | `perfis` |
| `AspNetRoleClaims` | `permissoes_perfis` |
| `AspNetUsers` | `usuarios` |
| `AspNetUserClaims` | `permissoes_usuarios` |
| `AspNetUserLogins` | `logins_usuarios` |
| `AspNetUserRoles` | `usuarios_perfis` |
| `AspNetUserTokens` | `tokens_usuarios` |
| `Categories` | `categorias` |
| `Suppliers` | `fornecedores` |
| `Parts` | `pecas` |
| `StockMovements` | `movimentacoes_estoque` |
| `Announcements` | `comunicados` |

## Colunas

| Nome anterior | Nome atual |
|---|---|
| `Id` | `id` |
| `Name` | `nome` |
| `Description` | `descricao` |
| `IsActive` | `ativo` |
| `CreatedAtUtc` | `criado_em_utc` |
| `TaxId` | `documento_fiscal` |
| `Phone` | `telefone` |
| `Email` | `email` |
| `Address` | `endereco` |
| `Code` | `codigo` |
| `CategoryId` | `categoria_id` |
| `SupplierId` | `fornecedor_id` |
| `StockQuantity` | `quantidade_estoque` |
| `MinimumStock` | `estoque_minimo` |
| `UnitPrice` | `preco_unitario` |
| `WarehouseLocation` | `localizacao_deposito` |
| `UpdatedAtUtc` | `atualizado_em_utc` |
| `Version` | `versao` |
| `PartId` | `peca_id` |
| `Type` | `tipo` |
| `Quantity` | `quantidade` |
| `PreviousBalance` | `saldo_anterior` |
| `NewBalance` | `saldo_posterior` |
| `Notes` | `observacao` |
| `OccurredAtUtc` | `ocorrido_em_utc` |
| `UserId` | `usuario_id` |
| `Title` | `titulo` |
| `Content` | `conteudo` |
| `PublishedAtUtc` | `publicado_em_utc` |
| `IsPublished` | `publicado` |
| `IsArchived` | `arquivado` |
| `AuthorId` | `autor_id` |
| `DisplayName` | `nome_exibicao` |
| `UserName` | `nome_usuario` |
| `NormalizedUserName` | `nome_usuario_normalizado` |
| `NormalizedEmail` | `email_normalizado` |
| `EmailConfirmed` | `email_confirmado` |
| `PasswordHash` | `hash_senha` |
| `SecurityStamp` | `marca_seguranca` |
| `ConcurrencyStamp` | `marca_concorrencia` |
| `PhoneNumber` | `numero_telefone` |
| `PhoneNumberConfirmed` | `telefone_confirmado` |
| `TwoFactorEnabled` | `dois_fatores_habilitado` |
| `LockoutEnd` | `fim_bloqueio` |
| `LockoutEnabled` | `bloqueio_habilitado` |
| `AccessFailedCount` | `tentativas_falhas` |
| `NormalizedName` | `nome_normalizado` |
| `RoleId` | `perfil_id` |
| `ClaimType` | `tipo_permissao` |
| `ClaimValue` | `valor_permissao` |
| `LoginProvider` | `provedor_login` |
| `ProviderKey` | `chave_provedor` |
| `ProviderDisplayName` | `nome_exibicao_provedor` |
| `Value` | `valor` |

## Views, funcoes e triggers

| Nome anterior | Nome atual |
|---|---|
| `vw_stock_overview` | `visao_geral_estoque` |
| `vw_stock_movements_daily` | `movimentacoes_diarias` |
| `fn_optistock_set_updated_at` | `fn_atualizar_data_peca` |
| `fn_optistock_prevent_movement_change` | `fn_proteger_historico_movimentacoes` |
| `fn_optistock_stock_summary` | `fn_resumo_estoque` |
| `fn_optistock_movement_totals` | `fn_totais_movimentacoes` |
| `trg_parts_set_updated_at` | `trg_pecas_atualizar_data` |
| `trg_stockmovements_immutable` | `trg_movimentacoes_proteger_historico` |

## Instalacao ou atualizacao

Com o site parado, execute na pasta DataBase_Pim:

```powershell
psql -h localhost -U optistock_user -d optistock -v ON_ERROR_STOP=1 -f migrations/optistock-idempotent.sql
```

Depois inicie a versao atualizada do Site_Pim. Tambem e possivel deixar o site atualizado aplicar suas migrations automaticamente ao iniciar. Nao inicie uma versao antiga do site depois da renomeacao.

A migration remove as views auxiliares em portugues criadas pelo antigo `scripts/views-portugues.sql` para liberar os nomes das tabelas reais. As views de relatorio sao recriadas com suas colunas em portugues. Views externas personalizadas podem impedir a atualizacao; nao e usado `CASCADE` para remove-las.

Os scripts antigos de migrations continuam em ingles porque representam versoes anteriores do banco. A ultima migration faz a traducao tanto na instalacao nova quanto na atualizacao. Nao altere migrations antigas ja aplicadas.

A tabela tecnica `__EFMigrationsHistory` e suas colunas mantem o padrao do Entity Framework para preservar o reconhecimento das migrations existentes. Objetos internos do PostgreSQL tambem mantem seus nomes de sistema. Os valores `Entry` e `Exit` continuam compativeis com o enum da aplicacao; sao valores, nao nomes de objetos.

## Consultas

```sql
SELECT * FROM pecas ORDER BY nome;
SELECT * FROM categorias ORDER BY nome;
SELECT * FROM fornecedores ORDER BY nome;
SELECT * FROM visao_geral_estoque ORDER BY nome;
SELECT * FROM movimentacoes_estoque ORDER BY ocorrido_em_utc DESC LIMIT 50;
SELECT * FROM movimentacoes_diarias ORDER BY data_movimentacao_utc DESC;
SELECT * FROM fn_resumo_estoque();
SELECT * FROM fn_totais_movimentacoes('2026-10-01 00:00:00+00', '2026-11-01 00:00:00+00');
```

O cadastro de pecas e a atualizacao do saldo continuam na aplicacao. Os triggers atualizam a data da peca e protegem o historico de movimentacoes.
