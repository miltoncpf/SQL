SELECT
	MAIN.IDSUBPRODUTO,
	DESCRICAO,
	REFERENCIA,
	QTDPRODUTOVENDA,
	ESTOQUE.ESTOQUE1,
	ESTOQUE.ESTOQUE2
FROM
(SELECT     IDSUBPRODUTO,
            REFERENCIA,
            DESCRICAO,
            QTDPRODUTOVENDA
FROM        (SELECT PRODUTO.IDPRODUTO,
                        PRODUTO.IDSUBPRODUTO,
                        REFERENCIA,
                        PRODUTO.DESCRICAO AS DESCRICAO,
                        CAST(SUM(PRODUTO.QTDPRODUTO ) AS NUMERIC(30,6)) AS QTDPRODUTO,
                        CAST(SUM(PRODUTO.QTDPRODUTOVENDA ) AS NUMERIC(30,6)) AS QTDPRODUTOVENDA,
                        CAST(SUM(PRODUTO.VALTOTLIQUIDO) AS NUMERIC(30,6)) AS VALTOTLIQUIDO,
                        CAST(SUM(PRODUTO.LUCRO) AS NUMERIC(30,6)) AS LUCRO

            FROM        ((SELECT    ESTOQUE_ANALITICO.IDPRODUTO,
                                    ESTOQUE_ANALITICO.IDSUBPRODUTO,
                                    PRODUTO_GRADE.REFERENCIA,
                                    PRODUTO.DESCRCOMPRODUTO || ' '|| PRODUTO_GRADE.SUBDESCRICAO AS DESCRICAO,
                                    CASE OPERACAO_INTERNA.TIPOMOVIMENTO
                                        WHEN 'E' THEN
                                                        SUM( ESTOQUE_ANALITICO.QTDPRODUTO )  * -1
                                        ELSE
                                                        SUM( ESTOQUE_ANALITICO.QTDPRODUTO )
                                    END AS QTDPRODUTO,
                                    CASE OPERACAO_INTERNA.TIPOMOVIMENTO
                                        WHEN 'E' THEN
                                            0
                                        ELSE
                                                        SUM( ESTOQUE_ANALITICO.QTDPRODUTO )
                                    END AS QTDPRODUTOVENDA,
                                    CASE OPERACAO_INTERNA.TIPOMOVIMENTO
                                        WHEN 'E' THEN
                                                      SUM( ESTOQUE_ANALITICO.VALTOTLIQUIDO ) * -1
                                        ELSE
                                                                SUM( ESTOQUE_ANALITICO.VALTOTLIQUIDO )
                                    END AS VALTOTLIQUIDO,

                            CASE WHEN PRODUTO.TIPOBAIXAMESTRE = 'K' THEN
                                  (SELECT
                                            CASE OPERACAO_INTERNA.TIPOMOVIMENTO WHEN 'E' THEN
                                                SUM( COALESCE( EST.VALLUCRO, 0 ) * EST.QTDPRODUTO ) * -1
                                            ELSE
                                                SUM( COALESCE( EST.VALLUCRO, 0 ) * EST.QTDPRODUTO )
                                            END
                                  FROM
                                             ESTOQUE_ANALITICO AS EST
                                  WHERE
                                             COALESCE(EST.NUMSEQUENCIAKIT,0) = ESTOQUE_ANALITICO.NUMSEQUENCIA AND
                                             EST.IDPLANILHA = ESTOQUE_ANALITICO.IDPLANILHA AND
                                             EST.IDSUBPRODUTO IN (
                                             (
                                             SELECT
                                                        PRODKIT.IDSUBPRODUTO
                                             FROM
                                                        PRODUTO_KIT AS PRODKIT
                                             WHERE
                                                        PRODKIT.IDPRODUTOKIT = ESTOQUE_ANALITICO.IDPRODUTO AND
                                                        PRODKIT.IDSUBPRODUTOKIT = ESTOQUE_ANALITICO.IDSUBPRODUTO
                                             ))
                                    )
                            ELSE
                                CASE OPERACAO_INTERNA.TIPOMOVIMENTO WHEN 'E' THEN
                                                   SUM( COALESCE( ESTOQUE_ANALITICO.VALLUCRO, 0 ) * ESTOQUE_ANALITICO.QTDPRODUTO ) * -1
                                ELSE
                                                    SUM( COALESCE( ESTOQUE_ANALITICO.VALLUCRO, 0 ) * ESTOQUE_ANALITICO.QTDPRODUTO )
                                END
                            END AS LUCRO
                        FROM        (ESTOQUE_ANALITICO LEFT OUTER JOIN CLIENTE_FORNECEDOR AS VENDEDOR ON
                                    ESTOQUE_ANALITICO.IDVENDEDOR = VENDEDOR.IDCLIFOR),
                                    NOTAS,
                                    NOTAS_ENTRADA_SAIDA,
                                    CLIENTE_FORNECEDOR,
                                    OPERACAO_INTERNA,
                                    OPERACAO_INTERNA AS CONFIG,
                                    PRODUTO_GRADE,
                                    SECAO,
                                    GRUPO,
                                    SUBGRUPO,
                                    PRODUTO,
                                    CIDADES_IBGE

                        WHERE  CIDADES_IBGE.IDCIDADE = CLIENTE_FORNECEDOR.IDCIDADE AND
                                    CONFIG.IDOPERACAO = 3000 AND
                                    NOTAS.IDEMPRESA = NOTAS_ENTRADA_SAIDA.IDEMPRESA AND
                                    NOTAS.IDPLANILHA = NOTAS_ENTRADA_SAIDA.IDPLANILHA AND
                                    ESTOQUE_ANALITICO.IDOPERACAO = NOTAS_ENTRADA_SAIDA.IDOPERACAO AND
                                    PRODUTO.IDSECAO = SECAO.IDSECAO AND
                                    PRODUTO.IDGRUPO = GRUPO.IDGRUPO AND
                                    PRODUTO.IDSUBGRUPO = SUBGRUPO.IDSUBGRUPO AND
                                    PRODUTO.IDPRODUTO = PRODUTO_GRADE.IDPRODUTO AND
                                    PRODUTO_GRADE.IDPRODUTO = ESTOQUE_ANALITICO.IDPRODUTO AND
                                    PRODUTO_GRADE.IDSUBPRODUTO = ESTOQUE_ANALITICO.IDSUBPRODUTO AND
                                    NOTAS.IDCLIFOR = CLIENTE_FORNECEDOR.IDCLIFOR AND
                                    NOTAS.IDEMPRESA = ESTOQUE_ANALITICO.IDEMPRESA AND
                                    NOTAS.IDPLANILHA = ESTOQUE_ANALITICO.IDPLANILHA AND
                                    NOTAS.FLAGNOTACANCEL = 'F' AND
                                    ESTOQUE_ANALITICO.IDOPERACAO = OPERACAO_INTERNA.IDOPERACAO AND
                                    ESTOQUE_ANALITICO.IDSUBPRODUTO NOT IN
                                    	(SELECT   
									 		ESTOQUE_ANALITICO.IDSUBPRODUTO
								         FROM        
								         	(ESTOQUE_ANALITICO LEFT OUTER JOIN CLIENTE_FORNECEDOR AS VENDEDOR ON
								             ESTOQUE_ANALITICO.IDVENDEDOR = VENDEDOR.IDCLIFOR),
								             NOTAS,
								             NOTAS_ENTRADA_SAIDA,
								             CLIENTE_FORNECEDOR,
								             OPERACAO_INTERNA,
								             OPERACAO_INTERNA AS CONFIG,
								             PRODUTO_GRADE,
								             PRODUTO,
								             CIDADES_IBGE
								          WHERE  		
								          		CIDADES_IBGE.IDCIDADE = CLIENTE_FORNECEDOR.IDCIDADE AND
								                CONFIG.IDOPERACAO = 3000 AND
								                NOTAS.IDEMPRESA = NOTAS_ENTRADA_SAIDA.IDEMPRESA AND
								                NOTAS.IDPLANILHA = NOTAS_ENTRADA_SAIDA.IDPLANILHA AND
								                ESTOQUE_ANALITICO.IDOPERACAO = NOTAS_ENTRADA_SAIDA.IDOPERACAO AND
								                PRODUTO.IDPRODUTO = PRODUTO_GRADE.IDPRODUTO AND
								                PRODUTO_GRADE.IDPRODUTO = ESTOQUE_ANALITICO.IDPRODUTO AND
								                PRODUTO_GRADE.IDSUBPRODUTO = ESTOQUE_ANALITICO.IDSUBPRODUTO AND
								                NOTAS.IDEMPRESA = ESTOQUE_ANALITICO.IDEMPRESA AND
								                NOTAS.IDPLANILHA = ESTOQUE_ANALITICO.IDPLANILHA AND
								                NOTAS.FLAGNOTACANCEL = 'F' AND
								                ESTOQUE_ANALITICO.IDOPERACAO = OPERACAO_INTERNA.IDOPERACAO AND
								                ESTOQUE_ANALITICO.IDOPERACAO <> 1301 AND
								                OPERACAO_INTERNA.FLAGMOVPRODUTOS = 'T' AND
								                ( ( ESTOQUE_ANALITICO.NUMSEQUENCIAKIT IS NULL ) OR ( ESTOQUE_ANALITICO.NUMSEQUENCIAKIT <= 0 ) ) AND
								                (OPERACAO_INTERNA.TIPOMOVIMENTO IN ( 'V','E' ) ) AND
								                ESTOQUE_ANALITICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM AND
								                (NOTAS.SERIENOTA <> 'CAN' OR (NOTAS.SERIENOTA = 'CAN' AND CONFIG.TIPOMOVIMENTO = 'V')) AND
								                NOTAS_ENTRADA_SAIDA.DTMOVIMENTO = ESTOQUE_ANALITICO.DTMOVIMENTO AND
								                NOTAS_ENTRADA_SAIDA.TIPOITEMCATEGORIA NOT IN('D5', 'D8') AND
												(SELECT
													VDH.IDDEPARTAMENTO 
												FROM 
													VENDEDOR_DEPARTAMENTO_HIST AS VDH 
												WHERE 
													VDH.IDVENDEDOR = ESTOQUE_ANALITICO.IDVENDEDOR AND 
													VDH.DTCADASTRO = (SELECT 
																			MAX(VDH.DTCADASTRO) AS DT 
															          FROM 
															          		VENDEDOR_DEPARTAMENTO_HIST AS VDH 
															          WHERE 
																			VDH.IDVENDEDOR = ESTOQUE_ANALITICO.IDVENDEDOR AND 
																			VDH.DTCADASTRO <= NOTAS.DTMOVIMENTO)) = 19 AND 
																			vendedor.idclifor = 48315 
								              	GROUP BY  
									                ESTOQUE_ANALITICO.IDSUBPRODUTO) AND
                                    ESTOQUE_ANALITICO.IDOPERACAO <> 1301 AND
                                    OPERACAO_INTERNA.FLAGMOVPRODUTOS = 'T' AND
                                    ( ( ESTOQUE_ANALITICO.NUMSEQUENCIAKIT IS NULL ) OR ( ESTOQUE_ANALITICO.NUMSEQUENCIAKIT <= 0 ) ) AND
                                    (OPERACAO_INTERNA.TIPOMOVIMENTO IN ( 'V','E' ) ) AND
                                    ESTOQUE_ANALITICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM AND
                                    (NOTAS.SERIENOTA <> 'CAN' OR (NOTAS.SERIENOTA = 'CAN' AND CONFIG.TIPOMOVIMENTO = 'V')) AND
                                    NOTAS_ENTRADA_SAIDA.DTMOVIMENTO = ESTOQUE_ANALITICO.DTMOVIMENTO AND
                                    NOTAS_ENTRADA_SAIDA.TIPOITEMCATEGORIA NOT IN('D5', 'D8') AND
                                                    (SELECT
                                                         COUNT(0)
                                                    FROM
                                                         NOTAS_DEVOLUCAO,
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO,
                                                         NOTAS_ENTRADA_SAIDA AS ORIGEM_DEVOLUCAO
                                                    WHERE
                                                         NOTAS_DEVOLUCAO.IDEMPRESA = ESTOQUE_ANALITICO.IDEMPRESA AND
                                                         NOTAS_DEVOLUCAO.IDPLANILHA = ESTOQUE_ANALITICO.IDPLANILHA AND
                                                         NOTAS_DEVOLUCAO.NUMSEQUENCIADEVOLUCAO = ESTOQUE_ANALITICO.NUMSEQUENCIA AND
                                                         NOTAS_DEVOLUCAO.IDPRODUTO = ESTOQUE_ANALITICO.IDPRODUTO AND
                                                         NOTAS_DEVOLUCAO.IDSUBPRODUTO = ESTOQUE_ANALITICO.IDSUBPRODUTO AND
                                                         ORIGEM_DEVOLUCAO.IDEMPRESA = NOTAS_DEVOLUCAO.IDEMPRESA AND
                                                         ORIGEM_DEVOLUCAO.IDPLANILHA = NOTAS_DEVOLUCAO.IDPLANILHADEVOLUCAO AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.IDEMPRESA = NOTAS_DEVOLUCAO.IDEMPRESA AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.IDPLANILHA = NOTAS_DEVOLUCAO.IDPLANILHA AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.NUMSEQUENCIADEV = NOTAS_DEVOLUCAO.NUMSEQUENCIADEVOLUCAO AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.IDPRODUTO = NOTAS_DEVOLUCAO.IDPRODUTO AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.IDSUBPRODUTO = NOTAS_DEVOLUCAO.IDSUBPRODUTO AND
                                                         DEVOLUCAO_LOGISTICA_MOVIMENTO.FLAGGERARREENTREGA = 'T') = 0
							                                AND  	(SELECT
							                                			VDH.IDDEPARTAMENTO 
							                                		FROM 
							                                			VENDEDOR_DEPARTAMENTO_HIST AS VDH 
							                                		WHERE 
							                                			VDH.IDVENDEDOR = ESTOQUE_ANALITICO.IDVENDEDOR AND 
							                                			VDH.DTCADASTRO = (SELECT 
							                                								MAX(VDH.DTCADASTRO) AS DT 
							                                							FROM 
							                                								VENDEDOR_DEPARTAMENTO_HIST AS VDH 
							                                							WHERE 
															                                VDH.IDVENDEDOR = ESTOQUE_ANALITICO.IDVENDEDOR AND 
															                                VDH.DTCADASTRO <= NOTAS.DTMOVIMENTO)) = 15 
							                                AND vendedor.idclifor in( 33615) 
                                    GROUP BY  
	                                    ESTOQUE_ANALITICO.IDPRODUTO,
	                                    ESTOQUE_ANALITICO.IDSUBPRODUTO,
	                                    PRODUTO_GRADE.REFERENCIA,
	                                    PRODUTO.DESCRCOMPRODUTO,
	                                    PRODUTO_GRADE.SUBDESCRICAO,
	                                    OPERACAO_INTERNA.TIPOMOVIMENTO,
	                                    ESTOQUE_ANALITICO.QTDPRODUTO,
	                                    SECAO.IDSECAO,
	                                    GRUPO.IDGRUPO,
	                                    SUBGRUPO.IDSUBGRUPO,
	                                    PRODUTO.TIPOBAIXAMESTRE,
	                                    ESTOQUE_ANALITICO.IDPLANILHA,
	                                    ESTOQUE_ANALITICO.NUMSEQUENCIA)
	                                         ) AS PRODUTO
        GROUP BY    PRODUTO.IDPRODUTO,
                    PRODUTO.IDSUBPRODUTO,
                    REFERENCIA,
                    PRODUTO.DESCRICAO
        ) AS TODAS
ORDER BY
        	QTDPRODUTO DESC) MAIN LEFT JOIN 
(SELECT
	EST_LOJA1.IDSUBPRODUTO,
	ESTOQUE1,
	ESTOQUE2
FROM
	(SELECT 
		IDSUBPRODUTO,
		SUM(QTDATUALESTOQUE)+0 ESTOQUE1
	FROM
		ESTOQUE_SALDO_ATUAL
	WHERE
		IDLOCALESTOQUE = 1
	GROUP BY
		IDSUBPRODUTO) EST_LOJA1 INNER JOIN
	(SELECT 
		IDSUBPRODUTO,
		SUM(QTDATUALESTOQUE)+0 ESTOQUE2
	FROM
		ESTOQUE_SALDO_ATUAL
	WHERE
		IDLOCALESTOQUE = 21
	GROUP BY
		IDSUBPRODUTO) EST_LOJA2 ON EST_LOJA1.IDSUBPRODUTO = EST_LOJA2.IDSUBPRODUTO) ESTOQUE ON MAIN.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO 
	