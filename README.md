# Teste Técnico - Pipeline de Dados com Apache Hop, dbt e PostgreSQL

Este repositório contém a solução do teste técnico para engenharia de dados. A arquitetura foi desenhada para processar os dados da base relacional **Northwind** (origem), realizar a extração e carga no **Data Warehouse** via **Apache Hop** (utilizando arquitetura orientada a metadados), e efetuar as transformações analíticas utilizando **dbt**.

---

##  Tech Stack

* **Containerização:** Docker & Docker Compose / VS Code Dev Containers
* **Orquestração & Ingestão (ETL):** Apache Hop 
* **Banco de Dados Origem:** PostgreSQL 15 (`northwind`)
* **Data Warehouse (Destino):** PostgreSQL 15 (`arruda_dw`)
* **Transformação & Modelagem:** dbt (data build tool) & Python 3.11

---

##  Como Executar o Projeto

### Pré-requisitos
* Docker e Docker Desktop instalados
* VS Code com a extensão **Dev Containers** instalada (recomendado)

### Passo a Passo

1. **Clonar o Repositório:**
   ```bash
   git clone https://github.com/AugustoYM25/arruda-teste-data-engineer
   cd teste-tecnico
   ```

2. **Configurar as Variáveis de Ambiente:**
   Crie o arquivo `.env` na pasta `.devcontainer/` a partir do template fornecido:
   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```

3. **Subir os Containers:**
   * **Via Terminal:**
     ```bash
     docker compose -f .devcontainer/docker-compose.yml up -d
     ```

4. **Acessar os Serviços:**
   * **Apache Hop (Web GUI):** `http://localhost:8080`
   * **Banco Origem (Northwind):** `localhost:5432` (Usuário: `postgres` | Senha: `password` | BD: `northwind`)
   * **Banco Destino (DW):** `localhost:5433` (Usuário: `dw_user` | Senha: `dw_password` | BD: `arruda_dw`)

5. **Executar a Carga de Dados (Apache Hop):**
   * Abra a interface do Apache Hop em `http://localhost:8080`.
   * Execute o workflow/pipeline principal responsável pela ingestão e povoamento do schema `etl.pipeline_metadata` e carga bruta das tabelas.

6. **Executar os Modelos do dbt:**
   No terminal da aplicação (`workspace`):
   ```bash
   cd dbt_project # ou pasta correspondente
   dbt deps
   dbt run
   dbt test
   ```

---

## Decisões Tomadas

1. **Arquitetura Containerizada & Isolada:**
   * Toda a infraestrutura roda via Docker Compose com dois bancos de dados isolados para simular um ambiente real de ELT/ETL (Banco Transacional x Data Warehouse).

2. **Gerenciamento de Metadados no Apache Hop:**
   * Foi criada uma tabela dedicada de metadados (`etl.pipeline_metadata`) no PostgreSQL para controlar o fluxo de execução das tabelas, permitindo parametrização dinâmica de cargas e facilidade no rastreio do pipeline.

3. **Separação de Responsabilidades (ELT Pattern):**
   * **Apache Hop:** Responsável pela extração (*Extract*) e carga (*Load*) dos dados brutos no DW.
   * **dbt:** Responsável pelas transformações (*Transform*), construindo as camadas analíticas (Staging, Intermediate e Marts/Dimensional) diretamente dentro do banco de destino.

4. **Segurança e Configurabilidade:**
   * Centralização de credenciais e portas no arquivo `.env` ignorado pelo Versionador de Código, mantendo a estrutura exposta através do `.env.example`.

---

##  Inconsistências Encontradas e Tratamentos

| Entidade / Tabela | Inconsistência Encontrada | Tratamento Aplicado |
| :--- | :--- | :--- |
 (*case sensitivity*). | Aplicação de funções `TRIM()` e padronização para caixa alta/baixa via dbt/Hop. |
| **Registros Nulos (Valores Ausentes)** | Colunas de endereço/região (`Region`, `PostalCode`) com valores `NULL` no banco Northwind. | Tratados na camada de staging do dbt substituindo nulos por valores padrão (ex: `'N/A'` ou `'Não Informado'`). |
| **Tipagem de Dados** | Datas armazenadas em formato genérico (`VARCHAR` ou `TIMESTAMP` sem fuso). | Conversão e *casting* explícito para tipos `DATE` / `TIMESTAMP` padronizados no PostgreSQL. |
| **Chaves Estrangeiras Órfãs** | Registros sem vínculo direto na tabela pai. | Aplicação de validações e testes de integridade referencial via `dbt test`. |

---

## O que faria com mais tempo

1. **Orquestração Automatizada:**
   * Implementação de uma ferramenta de orquestração (como Apache Airflow ou Dagster) ou agendador nativo do Hop para rodar a esteira completa (Hop -> dbt -> dbt test) em schedules definidos.

2. **Carga Incremental:**
   * Evolução das pipelines de carga do Apache Hop e dos modelos dbt para utilizarem estratégia de carga incremental baseada em marca d'água (*Watermark* / `updated_at`), em vez de *Full Refresh*.

3. **Visualização de Dados:**
   * Conexão de uma ferramenta de BI (*Metabase* ou *Superset*) via container para expor dashboards analíticos diretamente a partir do modelo dimensional gerado pelo dbt.