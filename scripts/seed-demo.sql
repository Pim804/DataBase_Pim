\set ON_ERROR_STOP on
BEGIN;
SELECT pg_advisory_xact_lock(780130);
DO $$
DECLARE
 actor uuid;
 cat integer;
 fornecedor integer;
 part integer;
 i integer;
 j integer;
 balance integer;
 category_names text[] := ARRAY['Fixadores','Rolamentos','Correias','Filtros','Vedacoes','Ferramentas','Eletrica','Hidraulica','Lubrificantes','Transmissao'];
 item_names text[] := ARRAY['Parafuso sextavado','Rolamento blindado','Correia industrial','Filtro de oleo','Anel de vedacao','Chave combinada','Rele de comando','Conexao hidraulica','Graxa industrial','Engrenagem'];
BEGIN
 SELECT "id" INTO actor FROM "usuarios" WHERE "ativo" ORDER BY "criado_em_utc", "id" LIMIT 1;
 IF actor IS NULL THEN RAISE EXCEPTION 'Crie um usuario ativo pela aplicacao antes de executar a carga.'; END IF;
 FOR i IN 1..10 LOOP
  INSERT INTO "categorias" ("nome","descricao","ativo","criado_em_utc")
  VALUES ('Demo - ' || category_names[i], 'Categoria ficticia para demonstracao do estoque.',true,CURRENT_TIMESTAMP - interval '60 days')
  ON CONFLICT ("nome") DO NOTHING;
 END LOOP;
 FOR i IN 1..8 LOOP
  INSERT INTO "fornecedores" ("nome","documento_fiscal","telefone","email","endereco","ativo")
  SELECT 'Fornecedor Demo ' || i,NULL,NULL,'fornecedor' || i || '@example.invalid','Endereco ficticio para demonstracao',true
  WHERE NOT EXISTS (SELECT 1 FROM "fornecedores" WHERE "email" = 'fornecedor' || i || '@example.invalid');
 END LOOP;
 FOR i IN 1..100 LOOP
  j := ((i-1) % 10)+1;
  SELECT "id" INTO cat FROM "categorias" WHERE "nome" = 'Demo - ' || category_names[j];
  SELECT "id" INTO fornecedor FROM "fornecedores" WHERE "email" = 'fornecedor' || (((i-1)%8)+1) || '@example.invalid' ORDER BY "id" LIMIT 1;
  balance := CASE WHEN i%10=0 THEN 0 WHEN i%5=0 THEN 5 ELSE 20+(i%50) END;
  part := NULL;
  INSERT INTO "pecas" ("codigo","nome","descricao","categoria_id","fornecedor_id","quantidade_estoque","estoque_minimo","preco_unitario","localizacao_deposito","ativo","criado_em_utc","atualizado_em_utc","versao")
  VALUES ('DEMO-' || lpad(i::text,4,'0'),item_names[j] || ' - modelo ' || (((i-1)/10)+1), 'Peca ficticia para demonstracao e testes.',cat,fornecedor,balance,10,(5+i*3.75)::numeric(12,2),'Corredor ' || j || ' / Prateleira ' || (((i-1)/10)+1),i%17<>0,CURRENT_TIMESTAMP-interval '60 days',CURRENT_TIMESTAMP,1)
  ON CONFLICT ("codigo") DO NOTHING RETURNING "id" INTO part;
  IF part IS NOT NULL THEN
   INSERT INTO "movimentacoes_estoque" ("peca_id","tipo","quantidade","saldo_anterior","saldo_posterior","observacao","ocorrido_em_utc","usuario_id") VALUES
   (part,'Entry',balance+15,0,balance+15,'DEMO: recebimento inicial',CURRENT_TIMESTAMP-interval '45 days'+i*interval '1 minute',actor),
   (part,'Exit',10,balance+15,balance+5,'DEMO: consumo na manutencao',CURRENT_TIMESTAMP-interval '20 days'+i*interval '1 minute',actor),
   (part,'Exit',5,balance+5,balance,'DEMO: retirada para operacao',CURRENT_TIMESTAMP-interval '2 days'+i*interval '1 minute',actor);
  END IF;
 END LOOP;
 FOR i IN 1..6 LOOP
  INSERT INTO "comunicados" ("titulo","conteudo","criado_em_utc","publicado_em_utc","publicado","arquivado","autor_id")
  SELECT 'DEMO - ' || (ARRAY['Conferencia de estoque','Organizacao do deposito','Reposicao de itens','Uso de equipamentos','Inventario mensal','Rotina de recebimento'])[i],
  'Comunicado ficticio para demonstracao. Confira os registros e siga os procedimentos internos de estoque.',CURRENT_TIMESTAMP-i*interval '1 day',CASE WHEN i=6 THEN NULL ELSE CURRENT_TIMESTAMP-i*interval '1 day' END,i<>6,i=5,actor
  WHERE NOT EXISTS (SELECT 1 FROM "comunicados" WHERE "titulo" = 'DEMO - ' || (ARRAY['Conferencia de estoque','Organizacao do deposito','Reposicao de itens','Uso de equipamentos','Inventario mensal','Rotina de recebimento'])[i]);
 END LOOP;
 IF EXISTS (
  SELECT 1 FROM "pecas" p JOIN LATERAL (SELECT "saldo_posterior" FROM "movimentacoes_estoque" m WHERE m."peca_id"=p."id" ORDER BY "ocorrido_em_utc" DESC,"id" DESC LIMIT 1) m ON true
  WHERE p."codigo" LIKE 'DEMO-%' AND p."quantidade_estoque"<>m."saldo_posterior"
 ) THEN RAISE EXCEPTION 'Saldo da peca divergente do historico.'; END IF;
END $$;
COMMIT;
SELECT 'categorias' AS entidade, count(*) FROM "categorias" WHERE "nome" LIKE 'Demo - %'
UNION ALL SELECT 'fornecedores',count(*) FROM "fornecedores" WHERE "email" LIKE '%@example.invalid'
UNION ALL SELECT 'pecas',count(*) FROM "pecas" WHERE "codigo" LIKE 'DEMO-%'
UNION ALL SELECT 'movimentacoes',count(*) FROM "movimentacoes_estoque" WHERE "observacao" LIKE 'DEMO:%'
UNION ALL SELECT 'comunicados',count(*) FROM "comunicados" WHERE "titulo" LIKE 'DEMO - %';
