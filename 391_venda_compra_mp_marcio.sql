-- GADGET 391 "VENDAS/COMPRA MP-MARCIO" -- dois blocos, no mesmo formato visual do
-- componente 94 (PORTAL DE VENDAS em cima, PORTAL DE COMPRAS embaixo).
--
-- Diferenca-chave para o 94: aqui o BLOCO 2 (compras) NAO tem prompt-parameter de
-- periodo proprio -- ele e alimentado pela nota de venda SELECIONADA no BLOCO 1
-- (grid mestre/detalhe), via o parametro :NUNOTA_VENDA. Isso elimina o problema
-- original (compra e venda com datas divergentes nao batiam mais no AG 35).
--
-- IMPORTANTE: eu nao configurei o link mestre/detalhe entre as duas grids no
-- Construtor de Componentes (isso fica com voce, no gear da grid / propriedades
-- da grid detalhe). O nome exato do parametro que o Sankhya gera para "campo
-- vindo da grid mestre" pode nao ser literalmente ":NUNOTA_VENDA" -- ajuste o
-- bind abaixo (so essa linha) para o nome que o Construtor de Componentes criar
-- quando voce ligar BLOCO 2 -> BLOCO 1 pelo campo NUNOTA.

-- ============================================================
-- BLOCO 1 - PORTAL DE VENDAS (grid mestre)
-- prompt-parameters: PERIODO (datePeriod), MERCADO (multiList ME/MI),
--                     OP (multiList operacao), P_FRUTA (multiList sql AD_FRUTA)
-- ============================================================
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
ORDER BY CAB.NUNOTA;


-- ============================================================
-- BLOCO 2 - PORTAL DE COMPRAS (grid detalhe, ligada ao BLOCO 1 por NUNOTA)
-- unico parametro: :NUNOTA_VENDA  <- ajustar nome se o Construtor gerar outro
-- (SEM prompt-parameter de periodo -- de proposito, para nao repetir o bug do AG 35)
-- ============================================================
WITH VENDA_SEL AS (
    SELECT ITE.NUNOTA, ITE.SEQUENCIA, ITE.CODPROD, ITE.CONTROLE, ITE.AD_PALLET
    FROM TGFITE ITE
    WHERE ITE.NUNOTA = :NUNOTA_VENDA
),
-- item de venda COM pallet: explode o pallet (linha a linha) -> romaneio + produtor
ROMANEIO_PALLET AS (
    SELECT
        VS.NUNOTA, VS.SEQUENCIA,
        TO_CHAR(PL.PITE_LOTE)  ROMANEIO,
        PL.PITE_CODPRODUTOR    CODPARC_PRODUTOR
    FROM VENDA_SEL VS
    JOIN VW_ARG_DETALHA_PALLET PL ON PL.PAL_NROUNICO = VS.AD_PALLET
    WHERE VS.AD_PALLET IS NOT NULL
),
-- item de venda SEM pallet: o CONTROLE do item EH o romaneio
ROMANEIO_DIRETO AS (
    SELECT
        VS.NUNOTA, VS.SEQUENCIA,
        VS.CONTROLE   ROMANEIO,
        AR.CODPARC    CODPARC_PRODUTOR
    FROM VENDA_SEL VS
    JOIN AD_ROMANEIOENTR AR ON AR.CODPROD = VS.CODPROD AND TO_CHAR(AR.ROMANEIO) = VS.CONTROLE
    WHERE VS.AD_PALLET IS NULL AND VS.CONTROLE IS NOT NULL
),
ROMANEIOS AS (
    SELECT DISTINCT CODPARC_PRODUTOR, ROMANEIO FROM ROMANEIO_PALLET
    UNION
    SELECT DISTINCT CODPARC_PRODUTOR, ROMANEIO FROM ROMANEIO_DIRETO
)
SELECT
    PRJ.IDENTIFICACAO                      PROCESSO,
    PAR.CODPARC || '-' || PAR.NOMEPARC     PRODUTOR,
    CAB.NUNOTA,
    CAB.NUMNOTA                            NUMERONF,
    CAB.SERIENOTA,
    CAB.DTNEG,
    CAB.DTENTSAI                           DATASAIDA,
    CAB.CHAVENFE,
    CAB.TIPMOV,
    ITE.CODPROD,
    PRO.CODPROD || '-' || PRO.DESCRPROD    PRODUTO,
    ITE.CONTROLE,
    ITE.QTDNEG,
    ITE.VLRUNIT,
    ITE.VLRTOT
FROM ROMANEIOS R
JOIN TGFCAB CAB ON CAB.CODPARC = R.CODPARC_PRODUTOR
JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA AND ITE.CONTROLE = R.ROMANEIO
JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
LEFT JOIN TCSPRJ PRJ ON PRJ.CODPROJ = CAB.CODPROJ
WHERE CAB.STATUSNOTA = 'L'
  AND CAB.TIPMOV IN ('C','E')
ORDER BY CAB.NUNOTA;
