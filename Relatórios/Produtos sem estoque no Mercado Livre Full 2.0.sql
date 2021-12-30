SELECT 
	PGE.IDSUBPRODUTO,
	PG.DESCRRESPRODUTO,
	PPP.VALPRECOVAREJO,
	ESTOQUE_DISPONIVEL1,
	ESTOQUE_DISPONIVEL2,
	ESTOQUE_DISPONIVEL3
FROM 
	PRODUTO_GRADE_ECOMMERCE PGE LEFT JOIN ( --JUNTANDO O ESTOQUE DOS PRODUTOS A TABELA PRODUTO_GRADE_ECOMMERCE 
			SELECT IDSUBPRODUTO, COALESCE(SUM(QTDATUALESTOQUE),0) ESTOQUE_DISPONIVEL1
			FROM ESTOQUE_SALDO_ATUAL WHERE IDLOCALESTOQUE = 1
			GROUP BY IDSUBPRODUTO) ESTOQUE1 ON PGE.IDSUBPRODUTO = ESTOQUE1.IDSUBPRODUTO
		LEFT JOIN(
			SELECT IDSUBPRODUTO, COALESCE(SUM(QTDATUALESTOQUE),0) ESTOQUE_DISPONIVEL2
			FROM ESTOQUE_SALDO_ATUAL WHERE IDLOCALESTOQUE = 21
			GROUP BY IDSUBPRODUTO) ESTOQUE2 ON PGE.IDSUBPRODUTO = ESTOQUE2.IDSUBPRODUTO
		LEFT JOIN(
			SELECT IDSUBPRODUTO, COALESCE(SUM(QTDATUALESTOQUE),0)  ESTOQUE_DISPONIVEL3
			FROM ESTOQUE_SALDO_ATUAL WHERE IDLOCALESTOQUE = 31
			GROUP BY IDSUBPRODUTO) ESTOQUE3 ON PGE.IDSUBPRODUTO = ESTOQUE3.IDSUBPRODUTO,			
	PRODUTO_GRADE PG,
	POLITICA_PRECO_PRODUTO PPP,
	ESTOQUE_SALDO_ATUAL ESA
WHERE
	PGE.IDPRODUTO = ESA.IDPRODUTO AND 
	PGE.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PGE.IDPRODUTO = PG.IDPRODUTO  AND
	PGE.IDSUBPRODUTO = PG.IDSUBPRODUTO AND
	ESA.IDPRODUTO = PG.IDPRODUTO AND
	PGE.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PPP.IDSUBPRODUTO = ESA.IDSUBPRODUTO AND
	PPP.IDSUBPRODUTO = PG.IDSUBPRODUTO AND 
	PPP.IDSUBPRODUTO = PGE.IDSUBPRODUTO AND
	PPP.IDEMPRESA = 1 AND
	PPP.VALPRECOVAREJO > 0 AND
	IDCONFIGECOMMERCE = 2 AND 
	DESCRICAO IS NOT NULL AND
	PGE.IDSUBPRODUTO NOT IN( --LISTA OS PRODUTOS QUE NÃO TEM ESTOQUE NOS LOCAIS 19-MERCADO LIVRE FULL E 26-EM TRANSITO ML FULL
					SELECT IDSUBPRODUTO FROM ESTOQUE_SALDO_ATUAL 
					WHERE IDLOCALESTOQUE IN (19,26) AND QTDATUALESTOQUE > 0 
					GROUP BY IDSUBPRODUTO ) AND
	PGE.IDSUBPRODUTO IN( --LISTA OS PRODUTOS QUE TIVERAM PELO MENOS 1 VENDAS VIA MERCADO LIVRE FULL
					SELECT IDSUBPRODUTO FROM ESTOQUE_ANALITICO 
					WHERE IDOPERACAO = 1097 GROUP BY IDSUBPRODUTO )
GROUP BY
	PGE.IDSUBPRODUTO,
	PG.DESCRRESPRODUTO,
	PPP.VALPRECOVAREJO,
	ESTOQUE_DISPONIVEL1,
	ESTOQUE_DISPONIVEL2,
	ESTOQUE_DISPONIVEL3