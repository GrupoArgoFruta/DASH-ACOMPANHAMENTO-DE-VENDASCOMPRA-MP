set. 16, 2026

## **Reunião em 16 de set. de 2026 às 10:08 GMT-03:00**

Registros da reunião [Transcrição](https://docs.google.com/document/d/1A83nNZ4HZ687si7W-FVbgjBNnlR17DbitFqs_jfUcIU/edit?usp=drive_web&tab=t.408zsry6stx1) [Gravação](https://drive.google.com/file/d/14LZJzNk5qXP8ivJiMtHJWM7jAvQZ4Eie/view?usp=drive_web)&nbsp;

&nbsp;

&nbsp;

### **Resumo**

Revisão de tickets pendentes e análise de falhas no painel para otimização de relatórios de dados.

**Análise de chamados técnicos**  
Volume de 40 chamados pendentes requer atenção contínua. Ferramentas auxiliares foram introduzidas para otimizar as tarefas diárias.

**Falhas no painel AG 35**  
O painel AG 35 falha ao associar vendas externas a notas fiscais de compra. Divergências temporais entre compras e vendas causam inconsistências manuais.

**Novo desenvolvimento de relatório**  
Decidiu-se desenvolver um relatório dedicado utilizando a sintaxe de sistemas existentes para garantir a associação correta de dados. A implementação de novas habilidades no Gemini servirá como base de conhecimento.

&nbsp;

&nbsp;

### **Decisões**

## Alinhada

* **Novo relatório para associação de vendas** O relatório à parte será desenvolvido para associar corretamente as notas de compra dos produtores às vendas correspondentes.

&nbsp;

&nbsp;

### **Próximas etapas**

- [ ] \[Francisco Natanael Lopes Vasconcelos\] Criar Relatório: Desenvolver um novo dashboard ou relatório que relacione vendas e compras de produtores, utilizando o controle e o romaneio como critérios de associação.

- [ ] \[Márcio Cabral de Miranda\] Abrir Chamado: Registrar a solicitação de melhoria no sistema para que o desenvolvedor possa atuar na criação do novo dashboard.

- [ ] \[Márcio Cabral de Miranda\] Configurar Gemini: Receber e aplicar as instruções sobre como utilizar skills customizadas no Gemini para otimizar pesquisas e processos do sistema.

- [ ] \[Francisco Natanael Lopes Vasconcelos\] Compartilhar Skills: Enviar as skills desenvolvidas para a Agrofruta e orientar sobre a configuração no Gemini como base de conhecimento.

&nbsp;

&nbsp;

### **Detalhes**

* **Demandas de Suporte e Introdução de Ferramentas**: Márcio Cabral de Miranda e Francisco Natanael Lopes Vasconcelos discutem o volume de chamados pendentes, totalizando 40 chamados, com Francisco Natanael Lopes Vasconcelos mencionando o fechamento de cerca de cinco chamados mais simples por dia. Francisco Natanael Lopes Vasconcelos oferece habilidades (skills) criadas para o Gemini e o sistema SER para auxiliar nas tarefas de trabalho.

* **Problemas no Painel AG 35 na Associação de Compras e Vendas**: Márcio Cabral de Miranda apresenta um problema no painel AG 35, que exibe informações de compras e vendas de uvas em uma data específica (3 de setembro, data 3/09), mas não associa vendas específicas (como o mercado externo de exportação) às notas fiscais de compra dos produtores correspondentes. Márcio Cabral de Miranda aponta a falta de acesso direto ao sistema para identificar esses dados, enquanto Francisco Natanael Lopes Vasconcelos sugere verificar a montagem de paletes e os romaneios de entrada.

* **Análise de Períodos e Proposta de Novo Relatório**: Márcio Cabral de Miranda e Francisco Natanael Lopes Vasconcelos discutem como a filtragem por períodos gera divergências, pois as datas de compra podem anteceder as vendas em uma semana ou dez dias. Márcio Cabral de Miranda relata que Thiago passou cerca de uma hora e meia resolvendo esse processo manualmente na semana anterior. Para solucionar a lacuna de associação, Francisco Natanael Lopes Vasconcelos propõe criar um novo painel ou copiar a sintaxe do atual para incorporar adequadamente romaneios e controles.

* **Comparação com Painéis Existentes e Validação de Dados**: Francisco Natanael Lopes Vasconcelos e Márcio Cabral de Miranda comparam o painel AG 35 com outro relatório existente exclusivo para a Cruzeiro, que utiliza notas referenciadas. Francisco Natanael Lopes Vasconcelos demonstra o uso de números de controle e romaneios para cruzar pedidos de compra e faturamento, e Francisco Natanael Lopes Vasconcelos se compromete a desenvolver um relatório à parte mantendo a mesma sintaxe para garantir a correta associação dos dados.

* **Implementação de Habilidades no Gemini para Regras de Negócio**: Francisco Natanael Lopes Vasconcelos compartilha habilidades (skills) desenvolvidas para o Gemini voltadas para regras de negócio do sistema SER e do setor de packhouse, com o objetivo de servir como uma base de conhecimento secundária e reduzir o consumo de tokens. Márcio Cabral de Miranda destaca que essa ferramenta ajudará a solucionar problemas futuros e a interagir com o setor financeiro. Por fim, Francisco Natanael Lopes Vasconcelos solicita que Márcio Cabral de Miranda abra um chamado técnico para o ajuste do painel, e Márcio Cabral de Miranda confirma que abrirá a solicitação e avisará pelo chat.

&nbsp;

&nbsp;

*Revise as anotações do Gemini para checar se estão corretas. [Confira dicas e saiba como o Gemini faz anotações](https://support.google.com/meet/answer/14754931)*

*Como está a qualidade de **destas observações?** [Responda a uma breve pesquisa](https://google.qualtrics.com/jfe/form/SV_5bXzKQfylMIhSXc?confid=_GDZ9jJSZH5l8O23Y8S4DxIROBEBMgUIigIgABgFCA&detailLevel=standard&hasImages=False&entryPoint=footerMain&isGoogler=False) para nos dar seu feedback, incluindo o quanto as observações foram úteis para o que você precisa.*