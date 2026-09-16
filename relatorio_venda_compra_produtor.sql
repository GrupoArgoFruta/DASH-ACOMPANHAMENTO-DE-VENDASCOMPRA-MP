-- RELATORIO: NOTA DE VENDA x NOTAS DE COMPRA DOS PRODUTORES
-- Objetivo: para cada nota de venda, listar as notas de compra (produtores)
-- que efetivamente compoem aquela venda, para uso dos despachantes.
--
-- Validado em producao (sankhyaprod.argofruta.com / DBExplorer) em 16/09/2026:
--   - Caso COM pallet: venda NUNOTA 809089 (pallet 47955) -> VW_ARG_DETALHA_PALLET
--     (PITE_LOTE=6433, PITE_CODPRODUTOR=13928) -> 18 linhas de compra do mesmo
--     produtor/lote batendo por CODPARC+CONTROLE.
--   - Caso SEM pallet: venda NUNOTA 805008/805009 (CODPROD 9890, CONTROLE 17595)
--     -> AD_ROMANEIOENTR (CODPROD+ROMANEIO=CONTROLE, SEM filtrar pelo CODPARC da
--     venda, que e o comprador e nao o produtor) -> CODPARC 10023 -> bateu com
--     exatamente 1 nota de compra (NUNOTA 805009), mesmo produto, mesmo dia.
--
-- Pontos importantes (motivo de o AG 35 falhar):
--   1) O CODPROD da compra pode ser DIFERENTE do CODPROD da venda (materia-prima
--      x produto acabado) -- por isso a ligacao NAO usa CODPROD, so CODPARC+CONTROLE.
--   2) A relacao e N-PARA-N: uma venda pode puxar VARIAS notas de compra do mesmo
--      lote/produtor (varias entregas viraram uma unica venda).
--   3) A tabela COMPRA abaixo NAO tem filtro de periodo de proposito -- e
--      exatamente isso que resolve o problema do AG 35 (compra pode ser dias/
--      semanas/meses antes da venda).
--
-- Parametros (prompt-parameters) a criar no gadget -- mesmos IDs/metadata do
-- painel AG 35 (componente 94, "DASH ACOMPANHAMENTO DE VENDAS/COMPRA MP"):
--   PERIODO  -> metadata="datePeriod"                          (filtra a venda por DTENTSAI)
--   MERCADO  -> metadata="multiList:Text" (ME=Mercado Externo, MI=Mercado Interno)
--   OP       -> metadata="multiList:Text" (VENDA, DEVOLUCAO, TRANSFERENCIA, REFUGO,
--                COMPLEMENTAR, REMESSA, OUTROS)
--   P_FRUTA  -> metadata="multiList:Text" listType="sql"
--               SELECT CODFRUTA VALUE, NOME LABEL FROM AD_FRUTA

WITH VENDA AS (
    SELECT
        PRJ.IDENTIFICACAO                      PROCESSO,
        PAR.CODPARC || '-' || PAR.NOMEPARC     COMPRADOR,
        CAB.NUNOTA,
        CAB.NUMNOTA                            NUMERONF,
        CAB.SERIENOTA,
        CAB.DTNEG,
        CAB.DTENTSAI                           DATASAIDA,
        CAB.CHAVENFE,
        CAB.AD_EX_CONTAINER                    CONTAINER,
        NAV.AD_NAVIO                           VESSEL,
        CAB.AD_EX_DTPREVEMB                    ETD,
        CAB.AD_EX_DTPREVDES                    ETA,
        ITE.SEQUENCIA,
        ITE.CODPROD,
        PRO.CODPROD || '-' || PRO.DESCRPROD    PRODUTO,
        PRO.AD_CULTIVAR,
        ITE.QTDNEG,
        ITE.CONTROLE,
        ITE.AD_PALLET,
        (CASE WHEN UFS.CODPAIS = 55 THEN 'MI' ELSE 'ME' END) MERCADO
    FROM TGFCAB CAB
    JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
    JOIN TCSPRJ PRJ ON PRJ.CODPROJ = CAB.CODPROJ
    JOIN TGFTOP TOP ON TOP.CODTIPOPER = CAB.CODTIPOPER AND CAB.DHTIPOPER = TOP.DHALTER
    JOIN TSICID CID ON CID.CODCID = PAR.CODCID
    JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
    JOIN TSIPAI PAI ON PAI.CODPAIS = UFS.CODPAIS
    LEFT JOIN TGFVEI NAV ON NAV.CODVEICULO = CAB.AD_EX_NAVIO
    LEFT JOIN AD_FRUTA AF ON UPPER(AF.NOME) = UPPER(PRO.AD_CULTIVAR)
    WHERE CAB.STATUSNOTA = 'L'
      AND PRO.USOPROD IN ('T','R','V','M')
      AND UPPER(TOP.GRUPO) NOT IN ('AJUSTES')
      AND CAB.TIPMOV = 'V'
      AND CAB.DTENTSAI BETWEEN :PERIODO.INI AND :PERIODO.FIN
      AND (AF.CODFRUTA IN :P_FRUTA)
      AND (CASE WHEN UFS.CODPAIS = 55 THEN 'MI' ELSE 'ME' END) IN :MERCADO
      AND (CASE WHEN TOP.DESCROPER LIKE '%TRANSF%' THEN 'TRANSFERENCIA'
                WHEN TOP.DESCROPER LIKE '%REFUG%'  THEN 'REFUGO'
                WHEN TOP.DESCROPER LIKE '%VENDA%'  THEN 'VENDA'
                WHEN TOP.DESCROPER LIKE '%COMPLE%' THEN 'COMPLEMENTAR'
                WHEN TOP.DESCROPER LIKE '%DESIDR%' THEN 'REMESSA'
                ELSE 'OUTROS' END) IN :OP
),
-- venda COM pallet: linha a linha (sem agregar) o que compos o pallet -> romaneio + produtor
ROMANEIO_PALLET AS (
    SELECT
        V.NUNOTA, V.SEQUENCIA,
        TO_CHAR(PL.PITE_LOTE)   ROMANEIO,
        PL.PITE_CODPRODUTOR     CODPARC_PRODUTOR,
        PL.PITE_PAR_NOMEPARC    NOME_PRODUTOR
    FROM VENDA V
    JOIN VW_ARG_DETALHA_PALLET PL ON PL.PAL_NROUNICO = V.AD_PALLET
    WHERE V.AD_PALLET IS NOT NULL
),
-- venda SEM pallet: o CONTROLE do item de venda EH o romaneio; acha o produtor no romaneio de entrada
ROMANEIO_DIRETO AS (
    SELECT
        V.NUNOTA, V.SEQUENCIA,
        V.CONTROLE           ROMANEIO,
        AR.CODPARC           CODPARC_PRODUTOR,
        PAR2.NOMEPARC        NOME_PRODUTOR
    FROM VENDA V
    JOIN AD_ROMANEIOENTR AR ON AR.CODPROD = V.CODPROD AND TO_CHAR(AR.ROMANEIO) = V.CONTROLE
    LEFT JOIN TGFPAR PAR2 ON PAR2.CODPARC = AR.CODPARC
    WHERE V.AD_PALLET IS NULL AND V.CONTROLE IS NOT NULL
),
ROMANEIOS AS (
    SELECT * FROM ROMANEIO_PALLET
    UNION ALL
    SELECT * FROM ROMANEIO_DIRETO
),
-- notas de compra dos produtores -- DE PROPOSITO sem filtro de periodo
COMPRA AS (
    SELECT
        CAB.NUNOTA, CAB.NUMNOTA NUMERONF, CAB.SERIENOTA, CAB.DTNEG,
        CAB.CHAVENFE, CAB.CODPARC,
        ITE.CODPROD, PRO.DESCRPROD PRODUTO,
        ITE.CONTROLE, ITE.QTDNEG, ITE.VLRUNIT, ITE.VLRTOT
    FROM TGFCAB CAB
    JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE CAB.STATUSNOTA = 'L'
      AND CAB.TIPMOV IN ('C','E')
)
SELECT
    V.PROCESSO,
    V.COMPRADOR,
    V.NUNOTA          NUNOTA_VENDA,
    V.NUMERONF        NUMERONF_VENDA,
    V.SERIENOTA       SERIE_VENDA,
    V.DTNEG           DTNEG_VENDA,
    V.DATASAIDA       DATASAIDA_VENDA,
    V.MERCADO,
    V.CONTAINER,
    V.VESSEL,
    V.ETD,
    V.ETA,
    V.CHAVENFE        CHAVENFE_VENDA,
    V.PRODUTO,
    V.QTDNEG          QTD_VENDA,
    V.AD_PALLET       PALLET,
    V.CONTROLE        CONTROLE_VENDA,
    R.ROMANEIO,
    R.NOME_PRODUTOR   PRODUTOR,
    C.NUNOTA          NUNOTA_COMPRA,
    C.NUMERONF        NUMERONF_COMPRA,
    C.SERIENOTA       SERIE_COMPRA,
    C.DTNEG           DTNEG_COMPRA,
    C.CHAVENFE        CHAVENFE_COMPRA,
    C.PRODUTO         PRODUTO_COMPRA,
    C.QTDNEG          QTD_COMPRA,
    C.VLRUNIT         VLRUNIT_COMPRA,
    C.VLRTOT          VLRTOT_COMPRA
FROM VENDA V
JOIN ROMANEIOS R ON R.NUNOTA = V.NUNOTA AND R.SEQUENCIA = V.SEQUENCIA
JOIN COMPRA C    ON C.CODPARC = R.CODPARC_PRODUTOR AND C.CONTROLE = R.ROMANEIO
ORDER BY V.NUNOTA, C.NUNOTA
