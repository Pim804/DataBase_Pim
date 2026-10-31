-- Definicoes atuais de views, funcoes e triggers.
-- Referencia: a instalacao oficial e feita pelas migrations.
-- Nao executar isoladamente sobre um banco ja instalado (os triggers ja existem).

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
