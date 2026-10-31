START TRANSACTION;
DROP VIEW IF EXISTS categorias;
DROP VIEW IF EXISTS fornecedores;
DROP VIEW IF EXISTS pecas;
DROP VIEW IF EXISTS movimentacoes_estoque;
DROP VIEW IF EXISTS comunicados;
DROP VIEW IF EXISTS visao_geral_estoque;
DROP VIEW IF EXISTS movimentacoes_diarias;
DROP VIEW IF EXISTS vw_stock_overview;
DROP VIEW IF EXISTS vw_stock_movements_daily;
DROP TRIGGER IF EXISTS trg_parts_set_updated_at ON "Parts";
DROP TRIGGER IF EXISTS trg_stockmovements_immutable ON "StockMovements";
DROP FUNCTION IF EXISTS fn_optistock_movement_totals(timestamptz, timestamptz);
DROP FUNCTION IF EXISTS fn_optistock_stock_summary();
DROP FUNCTION IF EXISTS fn_optistock_prevent_movement_change();
DROP FUNCTION IF EXISTS fn_optistock_set_updated_at();

ALTER TABLE "Announcements" DROP CONSTRAINT "FK_Announcements_AspNetUsers_AuthorId";

ALTER TABLE "AspNetRoleClaims" DROP CONSTRAINT "FK_AspNetRoleClaims_AspNetRoles_RoleId";

ALTER TABLE "AspNetUserClaims" DROP CONSTRAINT "FK_AspNetUserClaims_AspNetUsers_UserId";

ALTER TABLE "AspNetUserLogins" DROP CONSTRAINT "FK_AspNetUserLogins_AspNetUsers_UserId";

ALTER TABLE "AspNetUserRoles" DROP CONSTRAINT "FK_AspNetUserRoles_AspNetRoles_RoleId";

ALTER TABLE "AspNetUserRoles" DROP CONSTRAINT "FK_AspNetUserRoles_AspNetUsers_UserId";

ALTER TABLE "AspNetUserTokens" DROP CONSTRAINT "FK_AspNetUserTokens_AspNetUsers_UserId";

ALTER TABLE "Parts" DROP CONSTRAINT "FK_Parts_Categories_CategoryId";

ALTER TABLE "Parts" DROP CONSTRAINT "FK_Parts_Suppliers_SupplierId";

ALTER TABLE "StockMovements" DROP CONSTRAINT "FK_StockMovements_AspNetUsers_UserId";

ALTER TABLE "StockMovements" DROP CONSTRAINT "FK_StockMovements_Parts_PartId";

ALTER TABLE "Suppliers" DROP CONSTRAINT "PK_Suppliers";

DROP INDEX "IX_Suppliers_TaxId";

ALTER TABLE "StockMovements" DROP CONSTRAINT "PK_StockMovements";

ALTER TABLE "StockMovements" DROP CONSTRAINT "CK_StockMovements_Balances_NonNegative";

ALTER TABLE "StockMovements" DROP CONSTRAINT "CK_StockMovements_Quantity_Positive";

ALTER TABLE "Parts" DROP CONSTRAINT "PK_Parts";

ALTER TABLE "Parts" DROP CONSTRAINT "CK_Parts_MinimumStock_NonNegative";

ALTER TABLE "Parts" DROP CONSTRAINT "CK_Parts_StockQuantity_NonNegative";

ALTER TABLE "Parts" DROP CONSTRAINT "CK_Parts_UnitPrice_NonNegative";

ALTER TABLE "Categories" DROP CONSTRAINT "PK_Categories";

ALTER TABLE "AspNetUserTokens" DROP CONSTRAINT "PK_AspNetUserTokens";

ALTER TABLE "AspNetUsers" DROP CONSTRAINT "PK_AspNetUsers";

ALTER TABLE "AspNetUserRoles" DROP CONSTRAINT "PK_AspNetUserRoles";

ALTER TABLE "AspNetUserLogins" DROP CONSTRAINT "PK_AspNetUserLogins";

ALTER TABLE "AspNetUserClaims" DROP CONSTRAINT "PK_AspNetUserClaims";

ALTER TABLE "AspNetRoles" DROP CONSTRAINT "PK_AspNetRoles";

ALTER TABLE "AspNetRoleClaims" DROP CONSTRAINT "PK_AspNetRoleClaims";

ALTER TABLE "Announcements" DROP CONSTRAINT "PK_Announcements";

ALTER TABLE "Suppliers" RENAME TO fornecedores;

ALTER TABLE "StockMovements" RENAME TO movimentacoes_estoque;

ALTER TABLE "Parts" RENAME TO pecas;

ALTER TABLE "Categories" RENAME TO categorias;

ALTER TABLE "AspNetUserTokens" RENAME TO tokens_usuarios;

ALTER TABLE "AspNetUsers" RENAME TO usuarios;

ALTER TABLE "AspNetUserRoles" RENAME TO usuarios_perfis;

ALTER TABLE "AspNetUserLogins" RENAME TO logins_usuarios;

ALTER TABLE "AspNetUserClaims" RENAME TO permissoes_usuarios;

ALTER TABLE "AspNetRoles" RENAME TO perfis;

ALTER TABLE "AspNetRoleClaims" RENAME TO permissoes_perfis;

ALTER TABLE "Announcements" RENAME TO comunicados;

ALTER TABLE fornecedores RENAME COLUMN "Email" TO email;

ALTER TABLE fornecedores RENAME COLUMN "Id" TO id;

ALTER TABLE fornecedores RENAME COLUMN "TaxId" TO documento_fiscal;

ALTER TABLE fornecedores RENAME COLUMN "Phone" TO telefone;

ALTER TABLE fornecedores RENAME COLUMN "Name" TO nome;

ALTER TABLE fornecedores RENAME COLUMN "IsActive" TO ativo;

ALTER TABLE fornecedores RENAME COLUMN "Address" TO endereco;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "Id" TO id;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "UserId" TO usuario_id;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "Type" TO tipo;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "Quantity" TO quantidade;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "PreviousBalance" TO saldo_anterior;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "PartId" TO peca_id;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "OccurredAtUtc" TO ocorrido_em_utc;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "Notes" TO observacao;

ALTER TABLE movimentacoes_estoque RENAME COLUMN "NewBalance" TO saldo_posterior;

ALTER INDEX "IX_StockMovements_UserId" RENAME TO ix_movimentacoes_estoque_usuario_id;

ALTER INDEX "IX_StockMovements_PartId_OccurredAtUtc" RENAME TO ix_movimentacoes_estoque_peca_id_ocorrido_em_utc;

ALTER TABLE pecas RENAME COLUMN "Id" TO id;

ALTER TABLE pecas RENAME COLUMN "WarehouseLocation" TO localizacao_deposito;

ALTER TABLE pecas RENAME COLUMN "Version" TO versao;

ALTER TABLE pecas RENAME COLUMN "UpdatedAtUtc" TO atualizado_em_utc;

ALTER TABLE pecas RENAME COLUMN "UnitPrice" TO preco_unitario;

ALTER TABLE pecas RENAME COLUMN "SupplierId" TO fornecedor_id;

ALTER TABLE pecas RENAME COLUMN "StockQuantity" TO quantidade_estoque;

ALTER TABLE pecas RENAME COLUMN "Name" TO nome;

ALTER TABLE pecas RENAME COLUMN "MinimumStock" TO estoque_minimo;

ALTER TABLE pecas RENAME COLUMN "IsActive" TO ativo;

ALTER TABLE pecas RENAME COLUMN "Description" TO descricao;

ALTER TABLE pecas RENAME COLUMN "CreatedAtUtc" TO criado_em_utc;

ALTER TABLE pecas RENAME COLUMN "Code" TO codigo;

ALTER TABLE pecas RENAME COLUMN "CategoryId" TO categoria_id;

ALTER INDEX "IX_Parts_SupplierId" RENAME TO ix_pecas_fornecedor_id;

ALTER INDEX "IX_Parts_Name" RENAME TO ix_pecas_nome;

ALTER INDEX "IX_Parts_Code" RENAME TO ix_pecas_codigo;

ALTER INDEX "IX_Parts_CategoryId_IsActive" RENAME TO ix_pecas_categoria_id_ativo;

ALTER TABLE categorias RENAME COLUMN "Id" TO id;

ALTER TABLE categorias RENAME COLUMN "Name" TO nome;

ALTER TABLE categorias RENAME COLUMN "IsActive" TO ativo;

ALTER TABLE categorias RENAME COLUMN "Description" TO descricao;

ALTER TABLE categorias RENAME COLUMN "CreatedAtUtc" TO criado_em_utc;

ALTER INDEX "IX_Categories_Name" RENAME TO ix_categorias_nome;

ALTER TABLE tokens_usuarios RENAME COLUMN "Value" TO valor;

ALTER TABLE tokens_usuarios RENAME COLUMN "Name" TO nome;

ALTER TABLE tokens_usuarios RENAME COLUMN "LoginProvider" TO provedor_login;

ALTER TABLE tokens_usuarios RENAME COLUMN "UserId" TO usuario_id;

ALTER TABLE usuarios RENAME COLUMN "Email" TO email;

ALTER TABLE usuarios RENAME COLUMN "Id" TO id;

ALTER TABLE usuarios RENAME COLUMN "UserName" TO nome_usuario;

ALTER TABLE usuarios RENAME COLUMN "TwoFactorEnabled" TO dois_fatores_habilitado;

ALTER TABLE usuarios RENAME COLUMN "SecurityStamp" TO marca_seguranca;

ALTER TABLE usuarios RENAME COLUMN "PhoneNumberConfirmed" TO telefone_confirmado;

ALTER TABLE usuarios RENAME COLUMN "PhoneNumber" TO numero_telefone;

ALTER TABLE usuarios RENAME COLUMN "PasswordHash" TO hash_senha;

ALTER TABLE usuarios RENAME COLUMN "NormalizedUserName" TO nome_usuario_normalizado;

ALTER TABLE usuarios RENAME COLUMN "NormalizedEmail" TO email_normalizado;

ALTER TABLE usuarios RENAME COLUMN "LockoutEnd" TO fim_bloqueio;

ALTER TABLE usuarios RENAME COLUMN "LockoutEnabled" TO bloqueio_habilitado;

ALTER TABLE usuarios RENAME COLUMN "IsActive" TO ativo;

ALTER TABLE usuarios RENAME COLUMN "EmailConfirmed" TO email_confirmado;

ALTER TABLE usuarios RENAME COLUMN "DisplayName" TO nome_exibicao;

ALTER TABLE usuarios RENAME COLUMN "CreatedAtUtc" TO criado_em_utc;

ALTER TABLE usuarios RENAME COLUMN "ConcurrencyStamp" TO marca_concorrencia;

ALTER TABLE usuarios RENAME COLUMN "AccessFailedCount" TO tentativas_falhas;

ALTER INDEX "UserNameIndex" RENAME TO ix_usuarios_nome_usuario_normalizado;

ALTER INDEX "IX_AspNetUsers_IsActive" RENAME TO ix_usuarios_ativo;

ALTER INDEX "EmailIndex" RENAME TO ix_usuarios_email_normalizado;

ALTER TABLE usuarios_perfis RENAME COLUMN "RoleId" TO perfil_id;

ALTER TABLE usuarios_perfis RENAME COLUMN "UserId" TO usuario_id;

ALTER INDEX "IX_AspNetUserRoles_RoleId" RENAME TO ix_usuarios_perfis_perfil_id;

ALTER TABLE logins_usuarios RENAME COLUMN "UserId" TO usuario_id;

ALTER TABLE logins_usuarios RENAME COLUMN "ProviderDisplayName" TO nome_exibicao_provedor;

ALTER TABLE logins_usuarios RENAME COLUMN "ProviderKey" TO chave_provedor;

ALTER TABLE logins_usuarios RENAME COLUMN "LoginProvider" TO provedor_login;

ALTER INDEX "IX_AspNetUserLogins_UserId" RENAME TO ix_logins_usuarios_usuario_id;

ALTER TABLE permissoes_usuarios RENAME COLUMN "Id" TO id;

ALTER TABLE permissoes_usuarios RENAME COLUMN "UserId" TO usuario_id;

ALTER TABLE permissoes_usuarios RENAME COLUMN "ClaimValue" TO valor_permissao;

ALTER TABLE permissoes_usuarios RENAME COLUMN "ClaimType" TO tipo_permissao;

ALTER INDEX "IX_AspNetUserClaims_UserId" RENAME TO ix_permissoes_usuarios_usuario_id;

ALTER TABLE perfis RENAME COLUMN "Id" TO id;

ALTER TABLE perfis RENAME COLUMN "NormalizedName" TO nome_normalizado;

ALTER TABLE perfis RENAME COLUMN "Name" TO nome;

ALTER TABLE perfis RENAME COLUMN "ConcurrencyStamp" TO marca_concorrencia;

ALTER INDEX "RoleNameIndex" RENAME TO ix_perfis_nome_normalizado;

ALTER TABLE permissoes_perfis RENAME COLUMN "Id" TO id;

ALTER TABLE permissoes_perfis RENAME COLUMN "RoleId" TO perfil_id;

ALTER TABLE permissoes_perfis RENAME COLUMN "ClaimValue" TO valor_permissao;

ALTER TABLE permissoes_perfis RENAME COLUMN "ClaimType" TO tipo_permissao;

ALTER INDEX "IX_AspNetRoleClaims_RoleId" RENAME TO ix_permissoes_perfis_perfil_id;

ALTER TABLE comunicados RENAME COLUMN "Id" TO id;

ALTER TABLE comunicados RENAME COLUMN "Title" TO titulo;

ALTER TABLE comunicados RENAME COLUMN "PublishedAtUtc" TO publicado_em_utc;

ALTER TABLE comunicados RENAME COLUMN "IsPublished" TO publicado;

ALTER TABLE comunicados RENAME COLUMN "IsArchived" TO arquivado;

ALTER TABLE comunicados RENAME COLUMN "CreatedAtUtc" TO criado_em_utc;

ALTER TABLE comunicados RENAME COLUMN "Content" TO conteudo;

ALTER TABLE comunicados RENAME COLUMN "AuthorId" TO autor_id;

ALTER INDEX "IX_Announcements_IsPublished_IsArchived_PublishedAtUtc" RENAME TO ix_comunicados_publicado_arquivado_publicado_em_utc;

ALTER INDEX "IX_Announcements_AuthorId" RENAME TO ix_comunicados_autor_id;

ALTER TABLE fornecedores ADD CONSTRAINT pk_fornecedores PRIMARY KEY (id);

ALTER TABLE movimentacoes_estoque ADD CONSTRAINT pk_movimentacoes_estoque PRIMARY KEY (id);

ALTER TABLE pecas ADD CONSTRAINT pk_pecas PRIMARY KEY (id);

ALTER TABLE categorias ADD CONSTRAINT pk_categorias PRIMARY KEY (id);

ALTER TABLE tokens_usuarios ADD CONSTRAINT pk_tokens_usuarios PRIMARY KEY (usuario_id, provedor_login, nome);

ALTER TABLE usuarios ADD CONSTRAINT pk_usuarios PRIMARY KEY (id);

ALTER TABLE usuarios_perfis ADD CONSTRAINT pk_usuarios_perfis PRIMARY KEY (usuario_id, perfil_id);

ALTER TABLE logins_usuarios ADD CONSTRAINT pk_logins_usuarios PRIMARY KEY (provedor_login, chave_provedor);

ALTER TABLE permissoes_usuarios ADD CONSTRAINT pk_permissoes_usuarios PRIMARY KEY (id);

ALTER TABLE perfis ADD CONSTRAINT pk_perfis PRIMARY KEY (id);

ALTER TABLE permissoes_perfis ADD CONSTRAINT pk_permissoes_perfis PRIMARY KEY (id);

ALTER TABLE comunicados ADD CONSTRAINT pk_comunicados PRIMARY KEY (id);

CREATE UNIQUE INDEX ix_fornecedores_documento_fiscal ON fornecedores (documento_fiscal) WHERE "documento_fiscal" IS NOT NULL;

ALTER TABLE movimentacoes_estoque ADD CONSTRAINT ck_movimentacoes_quantidade_positiva CHECK ("quantidade" > 0);

ALTER TABLE movimentacoes_estoque ADD CONSTRAINT ck_movimentacoes_saldos_nao_negativos CHECK ("saldo_anterior" >= 0 AND "saldo_posterior" >= 0);

ALTER TABLE pecas ADD CONSTRAINT ck_pecas_estoque_minimo_nao_negativo CHECK ("estoque_minimo" >= 0);

ALTER TABLE pecas ADD CONSTRAINT ck_pecas_preco_nao_negativo CHECK ("preco_unitario" >= 0);

ALTER TABLE pecas ADD CONSTRAINT ck_pecas_quantidade_nao_negativa CHECK ("quantidade_estoque" >= 0);

ALTER TABLE comunicados ADD CONSTRAINT fk_comunicados_usuarios_autor_id FOREIGN KEY (autor_id) REFERENCES usuarios (id) ON DELETE RESTRICT;

ALTER TABLE logins_usuarios ADD CONSTRAINT fk_logins_usuarios_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE;

ALTER TABLE movimentacoes_estoque ADD CONSTRAINT fk_movimentacoes_estoque_pecas_peca_id FOREIGN KEY (peca_id) REFERENCES pecas (id) ON DELETE RESTRICT;

ALTER TABLE movimentacoes_estoque ADD CONSTRAINT fk_movimentacoes_estoque_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE RESTRICT;

ALTER TABLE pecas ADD CONSTRAINT fk_pecas_categorias_categoria_id FOREIGN KEY (categoria_id) REFERENCES categorias (id) ON DELETE RESTRICT;

ALTER TABLE pecas ADD CONSTRAINT fk_pecas_fornecedores_fornecedor_id FOREIGN KEY (fornecedor_id) REFERENCES fornecedores (id) ON DELETE RESTRICT;

ALTER TABLE permissoes_perfis ADD CONSTRAINT fk_permissoes_perfis_perfis_perfil_id FOREIGN KEY (perfil_id) REFERENCES perfis (id) ON DELETE CASCADE;

ALTER TABLE permissoes_usuarios ADD CONSTRAINT fk_permissoes_usuarios_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE;

ALTER TABLE tokens_usuarios ADD CONSTRAINT fk_tokens_usuarios_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE;

ALTER TABLE usuarios_perfis ADD CONSTRAINT fk_usuarios_perfis_perfis_perfil_id FOREIGN KEY (perfil_id) REFERENCES perfis (id) ON DELETE CASCADE;

ALTER TABLE usuarios_perfis ADD CONSTRAINT fk_usuarios_perfis_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE;

ALTER TABLE "movimentacoes_estoque" RENAME CONSTRAINT "CK_StockMovements_Type_Valid" TO "ck_movimentacoes_tipo_valido";
ALTER TABLE "movimentacoes_estoque" RENAME CONSTRAINT "CK_StockMovements_Balance_Matches_Type" TO "ck_movimentacoes_saldo_coerente";
DO $renomear_sequencias$
DECLARE nome_atual text;
BEGIN
    nome_atual := pg_get_serial_sequence('"categorias"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'categorias_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"fornecedores"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'fornecedores_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"permissoes_perfis"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'permissoes_perfis_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"permissoes_usuarios"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'permissoes_usuarios_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"pecas"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'pecas_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"movimentacoes_estoque"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'movimentacoes_estoque_id_seq'); END IF;
    nome_atual := pg_get_serial_sequence('"comunicados"', 'id');
    IF nome_atual IS NOT NULL THEN EXECUTE format('ALTER SEQUENCE %s RENAME TO %I', nome_atual, 'comunicados_id_seq'); END IF;
END;
$renomear_sequencias$;
CREATE OR REPLACE FUNCTION fn_atualizar_data_peca()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."atualizado_em_utc" := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pecas_atualizar_data
BEFORE UPDATE ON "pecas"
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_data_peca();

CREATE OR REPLACE FUNCTION fn_proteger_historico_movimentacoes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Movimentacoes de estoque sao imutaveis; registre uma movimentacao de correcao.'
        USING ERRCODE = '55000';
END;
$$;

CREATE TRIGGER trg_movimentacoes_proteger_historico
BEFORE UPDATE OR DELETE ON "movimentacoes_estoque"
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_historico_movimentacoes();

CREATE OR REPLACE VIEW visao_geral_estoque AS
SELECT
    p."id" AS peca_id,
    p."codigo" AS codigo,
    p."nome" AS nome,
    c."nome" AS categoria,
    s."nome" AS fornecedor,
    p."quantidade_estoque" AS quantidade_estoque,
    p."estoque_minimo" AS estoque_minimo,
    p."preco_unitario" AS preco_unitario,
    (p."quantidade_estoque" * p."preco_unitario")::numeric(14, 2) AS valor_estoque,
    p."localizacao_deposito" AS localizacao_deposito,
    p."ativo" AS ativo,
    CASE
        WHEN NOT p."ativo" THEN 'Inativo'
        WHEN p."quantidade_estoque" = 0 THEN 'Sem estoque'
        WHEN p."quantidade_estoque" <= p."estoque_minimo" THEN 'Estoque baixo'
        ELSE 'Disponivel'
    END AS situacao_estoque,
    p."criado_em_utc" AS criado_em_utc,
    p."atualizado_em_utc" AS atualizado_em_utc
FROM "pecas" AS p
JOIN "categorias" AS c ON c."id" = p."categoria_id"
LEFT JOIN "fornecedores" AS s ON s."id" = p."fornecedor_id";

CREATE OR REPLACE VIEW movimentacoes_diarias AS
SELECT
    (m."ocorrido_em_utc" AT TIME ZONE 'UTC')::date AS data_movimentacao_utc,
    COUNT(*) FILTER (WHERE m."tipo" = 'Entry')::bigint AS numero_entradas,
    COUNT(*) FILTER (WHERE m."tipo" = 'Exit')::bigint AS numero_saidas,
    COALESCE(SUM(m."quantidade") FILTER (WHERE m."tipo" = 'Entry'), 0)::bigint AS quantidade_entradas,
    COALESCE(SUM(m."quantidade") FILTER (WHERE m."tipo" = 'Exit'), 0)::bigint AS quantidade_saidas
FROM "movimentacoes_estoque" AS m
GROUP BY (m."ocorrido_em_utc" AT TIME ZONE 'UTC')::date;

CREATE OR REPLACE FUNCTION fn_resumo_estoque()
RETURNS TABLE (
    pecas_ativas bigint,
    unidades_disponiveis bigint,
    pecas_estoque_baixo bigint,
    pecas_sem_estoque bigint,
    valor_estoque numeric
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        COUNT(*) FILTER (WHERE p."ativo")::bigint,
        COALESCE(SUM(p."quantidade_estoque") FILTER (WHERE p."ativo"), 0)::bigint,
        COUNT(*) FILTER (WHERE p."ativo" AND p."quantidade_estoque" > 0 AND p."quantidade_estoque" <= p."estoque_minimo")::bigint,
        COUNT(*) FILTER (WHERE p."ativo" AND p."quantidade_estoque" = 0)::bigint,
        COALESCE(SUM(p."quantidade_estoque" * p."preco_unitario") FILTER (WHERE p."ativo"), 0)::numeric
    FROM "pecas" AS p;
$$;

CREATE OR REPLACE FUNCTION fn_totais_movimentacoes(
    p_inicio timestamptz,
    p_fim timestamptz
)
RETURNS TABLE (
    numero_entradas bigint,
    numero_saidas bigint,
    quantidade_entradas bigint,
    quantidade_saidas bigint
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    IF p_inicio IS NULL OR p_fim IS NULL OR p_fim < p_inicio THEN
        RAISE EXCEPTION 'O periodo deve ter inicio e fim, com fim maior ou igual ao inicio.'
            USING ERRCODE = '22023';
    END IF;

    RETURN QUERY
    SELECT
        COUNT(*) FILTER (WHERE m."tipo" = 'Entry')::bigint,
        COUNT(*) FILTER (WHERE m."tipo" = 'Exit')::bigint,
        COALESCE(SUM(m."quantidade") FILTER (WHERE m."tipo" = 'Entry'), 0)::bigint,
        COALESCE(SUM(m."quantidade") FILTER (WHERE m."tipo" = 'Exit'), 0)::bigint
    FROM "movimentacoes_estoque" AS m
    WHERE m."ocorrido_em_utc" >= p_inicio
      AND m."ocorrido_em_utc" < p_fim;
END;
$$;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20261031222433_TraduzirNomesBanco', '10.0.12');

COMMIT;

