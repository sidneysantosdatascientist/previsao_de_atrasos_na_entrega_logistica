-- delivery_analysis_schema.sql
-- Schema revisado com boas práticas: listas de colunas em INSERTs, RESTART IDENTITY ao truncar,
-- índices recomendados, FK com ações explícitas e comentários.

BEGIN;

-- 1) Criar schema
CREATE SCHEMA IF NOT EXISTS delivery_analysis;

-- 2) Tabelas
-- Tabela de clientes
CREATE TABLE IF NOT EXISTS delivery_analysis.customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_segment VARCHAR(20),
    registration_date DATE,
    state VARCHAR(2),
    monthly_spend_avg NUMERIC(12,2),
    total_orders INTEGER DEFAULT 0,
    avg_delivery_rating NUMERIC(3,1),
    total_deliveries INTEGER DEFAULT 0,
    avg_delay_hours NUMERIC(8,2) DEFAULT 0,
    max_delay_hours INTEGER DEFAULT 0,
    delayed_deliveries INTEGER DEFAULT 0,
    avg_weight_kg NUMERIC(8,2) DEFAULT 0,
    delay_rate NUMERIC(5,4) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de entregas
CREATE TABLE IF NOT EXISTS delivery_analysis.deliveries (
    delivery_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    order_date DATE,
    estimated_delivery DATE,
    actual_delivery DATE,
    origin_city VARCHAR(100),
    destination_city VARCHAR(100),
    weight_kg NUMERIC(8,2),
    carrier VARCHAR(100),
    status VARCHAR(50),
    delay_hours INTEGER DEFAULT 0,
    is_delayed BOOLEAN DEFAULT FALSE,
    delivery_duration INTEGER, -- em horas ou dias conforme seu padrão
    estimated_duration INTEGER,
    delay_category VARCHAR(50),
    order_day_of_week VARCHAR(15),
    order_month INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_deliveries_customer FOREIGN KEY (customer_id)
        REFERENCES delivery_analysis.customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabela de KPIs
CREATE TABLE IF NOT EXISTS delivery_analysis.kpi_deliveries (
    kpi_id BIGSERIAL PRIMARY KEY,
    customer_id VARCHAR(20),
    carrier VARCHAR(100),
    origin_city VARCHAR(100),
    destination_city VARCHAR(100),
    total_deliveries INTEGER DEFAULT 0,
    delay_rate NUMERIC(5,4) DEFAULT 0,
    avg_delay_hours NUMERIC(8,2) DEFAULT 0,
    max_delay_hours INTEGER DEFAULT 0,
    avg_delivery_duration NUMERIC(8,2) DEFAULT 0,
    avg_weight_kg NUMERIC(8,2) DEFAULT 0,
    customer_segment VARCHAR(20),
    state VARCHAR(2),
    monthly_spend_avg NUMERIC(12,2),
    calculation_date DATE DEFAULT CURRENT_DATE
);

-- 3) Limpeza das tabelas
-- Use com cuidado em produção. RESTART IDENTITY reinicia sequências para tabelas com SERIAL/BIGSERIAL.
TRUNCATE TABLE delivery_analysis.kpi_deliveries RESTART IDENTITY CASCADE;
TRUNCATE TABLE delivery_analysis.deliveries RESTART IDENTITY CASCADE;
TRUNCATE TABLE delivery_analysis.customers RESTART IDENTITY CASCADE;

-- 4) Inserção de dados (sempre com lista explícita de colunas)
-- Clientes
INSERT INTO delivery_analysis.customers (
  customer_id, customer_name, customer_segment, registration_date,
  state, monthly_spend_avg, total_orders, avg_delivery_rating,
  total_deliveries, avg_delay_hours, max_delay_hours,
  delayed_deliveries, avg_weight_kg, delay_rate
) VALUES
('CUST001', 'Empresa A Ltda', 'Small', '2023-08-21','PR', 4384.65, 48, 3.9, 8, 21.0, 72, 4, 4.29, 0.5),
('CUST002', 'Empresa B Ltda', 'Small', '2023-04-08','MG', 13260.29, 33, 4.3, 8, 3.0, 24, 1, 4.95, 0.125),
('CUST003', 'Empresa C Ltda', 'Small', '2023-02-21','RS', 14201.19, 42, 3.6, 5, 4.8, 24, 1, 4.92, 0.2),
('CUST004', 'Empresa D Ltda', 'Medium', '2023-11-27','RS', 2299.81, 37, 4.9, 4, 12.0, 48, 1, 6.55, 0.25),
('CUST005', 'Empresa E Ltda', 'Small', '2023-04-25','MG', 6972.01, 12, 4.7, 9, 18.67, 72, 3, 5.28, 0.333),
('CUST006', 'Empresa F Ltda', 'Medium', '2023-04-25','SP', 2845.67, 23, 4.6, 3, 8.0, 24, 1, 5.53, 0.333),
('CUST007', 'Empresa G Ltda', 'Small', '2023-12-15','PR', 5001.62, 16, 4.2, 4, 36.0, 72, 3, 4.12, 0.75),
('CUST008', 'Empresa H Ltda', 'Enterprise', '2023-04-18','MG', 13821.17, 49, 4.5, 3, 16.0, 48, 1, 2.33, 0.333),
('CUST009', 'Empresa I Ltda', 'Medium', '2023-02-26','RJ', 9380.10, 43, 3.8, 6, 4.0, 24, 1, 5.57, 0.167),
('CUST010', 'Empresa J Ltda', 'Enterprise', '2023-08-21','RS', 2587.95, 25, 4.5, 3, 0.0, 0, 0, 6.67, 0.0),
('CUST011', 'Empresa K Ltda', 'Medium', '2023-12-13','RJ', 14548.32, 38, 4.6, 1, 0.0, 0, 0, 2.10, 0.0),
('CUST012', 'Empresa L Ltda', 'Small', '2023-12-08','SP', 12039.18, 33, 3.0, 3, 8.0, 24, 1, 6.57, 0.333),
('CUST013', 'Empresa M Ltda', 'Small', '2023-11-05','MG', 12272.28, 48, 4.3, 1, 0.0, 0, 0, 2.90, 0.0),
('CUST014', 'Empresa N Ltda', 'Enterprise', '2023-02-01','SP', 10102.88, 32, 4.3, 6, 0.0, 0, 0, 6.00, 0.0),
('CUST015', 'Empresa O Ltda', 'Medium', '2023-11-03','RS', 10288.25, 10, 3.8, 6, 8.0, 24, 2, 3.68, 0.333),
('CUST016', 'Empresa P Ltda', 'Enterprise', '2023-10-23','MG', 11890.21, 23, 4.0, 5, 0.0, 0, 0, 5.22, 0.0),
('CUST017', 'Empresa Q Ltda', 'Medium', '2023-03-07','RJ', 2330.45, 41, 4.4, 11, 21.82, 72, 4, 4.44, 0.364),
('CUST018', 'Empresa R Ltda', 'Small', '2023-04-13','PR', 9017.93, 41, 4.2, 4, 0.0, 0, 0, 5.30, 0.0),
('CUST019', 'Empresa S Ltda', 'Medium', '2023-09-21','RS', 14086.07, 15, 3.9, 5, 28.8, 72, 2, 2.72, 0.4),
('CUST020', 'Empresa T Ltda', 'Small', '2023-11-26','RS', 13603.27, 37, 3.7, 5, 19.2, 72, 2, 7.02, 0.4
);

-- Entregas 
INSERT INTO delivery_analysis.deliveries (
  delivery_id, customer_id, order_date, estimated_delivery, actual_delivery,
  origin_city, destination_city, weight_kg, carrier, status,
  delay_hours, is_delayed, delivery_duration, estimated_duration,
  delay_category, order_day_of_week, order_month
) VALUES
('DEL001','CUST001','2024-01-25','2024-01-29','2024-01-29','Porto Alegre','Recife',8.7,'Transportadora C','Entregue',0,false,4,4,'Small Delay','Thursday',1),
('DEL002','CUST006','2024-03-09','2024-03-15','2024-03-15','Rio de Janeiro','Curitiba',2.8,'Transportadora C','Entregue',0,false,6,6,'Small Delay','Saturday',3),
('DEL003','CUST009','2024-01-17','2024-01-20','2024-01-20','Recife','Belo Horizonte',7.3,'Transportadora A','Entregue',0,false,3,3,'Small Delay','Wednesday',1),
('DEL004','CUST017','2024-01-27','2024-01-29','2024-01-29','Porto Alegre','Fortaleza',0.8,'Transportadora A','Entregue',0,false,2,2,'Small Delay','Saturday',1),
('DEL005','CUST001','2024-03-02','2024-03-08','2024-03-08','Recife','Curitiba',1.3,'Transportadora C','Entregue',0,false,6,6,'Small Delay','Saturday',3),
('DEL006','CUST017','2024-03-06','2024-03-12','2024-03-12','Recife','Fortaleza',5.6,'Transportadora A','Entregue',0,false,6,6,'Small Delay','Wednesday',3),
('DEL007','CUST009','2024-03-06','2024-03-12','2024-03-12','Porto Alegre','Porto Alegre',2.6,'Transportadora B','Entregue',0,false,6,6,'Small Delay','Wednesday',3),
('DEL008','CUST003','2024-03-19','2024-03-24','2024-03-24','Porto Alegre','Rio de Janeiro',7.1,'Transportadora C','Entregue',0,false,5,5,'Small Delay','Tuesday',3),
('DEL009','CUST018','2024-01-11','2024-01-16','2024-01-16','Rio de Janeiro','Fortaleza',7.1,'Transportadora C','Entregue',0,false,5,5,'Small Delay','Thursday',1),
('DEL010','CUST016','2024-02-16','2024-02-18','2024-02-18','São Paulo','Belo Horizonte',10.0,'Transportadora B','Entregue',0,false,2,2,'Small Delay','Friday',2);

-- KPIs de exemplo
INSERT INTO delivery_analysis.kpi_deliveries (
  customer_id, carrier, origin_city, destination_city,
  total_deliveries, delay_rate, avg_delay_hours, max_delay_hours,
  avg_delivery_duration, avg_weight_kg, customer_segment, state, monthly_spend_avg
) VALUES
('CUST001','Transportadora A','Curitiba','Recife',1,1.0,24.0,24,4.0,0.9,'Small','PR',4384.65),
('CUST001','Transportadora B','Curitiba','Curitiba',1,1.0,24.0,24,4.0,1.5,'Small','PR',4384.65),
('CUST002','Transportadora A','Rio de Janeiro','Recife',1,0.0,0.0,0,5.0,9.4,'Small','MG',13260.29),
('CUST002','Transportadora B','Fortaleza','Fortaleza',1,0.0,0.0,0,4.0,3.2,'Small','MG',13260.29);

-- 5) Índices recomendados para performance
CREATE INDEX IF NOT EXISTS idx_deliveries_customer_id ON delivery_analysis.deliveries (customer_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_carrier ON delivery_analysis.deliveries (carrier);
CREATE INDEX IF NOT EXISTS idx_deliveries_order_date ON delivery_analysis.deliveries (order_date);
CREATE INDEX IF NOT EXISTS idx_deliveries_origin_dest ON delivery_analysis.deliveries (origin_city, destination_city);

-- 6) Views úteis 
CREATE OR REPLACE VIEW delivery_analysis.vw_carrier_performance AS
SELECT 
  carrier,
  COUNT(*) AS total_deliveries,
  SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) AS delayed_deliveries,
  ROUND(AVG(delay_hours)::numeric,2) AS avg_delay_hours,
  MAX(delay_hours) AS max_delay_hours,
  ROUND(100.0 * SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS delay_rate_pct
FROM delivery_analysis.deliveries
GROUP BY carrier;

CREATE OR REPLACE VIEW delivery_analysis.vw_customer_delay_summary AS
SELECT 
  c.customer_id,
  c.customer_name,
  c.customer_segment,
  c.state,
  COUNT(d.delivery_id) AS total_deliveries,
  SUM(CASE WHEN d.is_delayed THEN 1 ELSE 0 END) AS delayed_deliveries,
  ROUND(100.0 * SUM(CASE WHEN d.is_delayed THEN 1 ELSE 0 END) / NULLIF(COUNT(d.delivery_id),0), 2) AS delay_rate_pct,
  ROUND(AVG(d.delay_hours)::numeric, 2) AS avg_delay_hours
FROM delivery_analysis.customers c
LEFT JOIN delivery_analysis.deliveries d ON c.customer_id = d.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.state;

COMMIT;

-- Fim do script




-- 1. ESTATÍSTICAS GERAIS
SELECT 
    COUNT(*) as total_entregas,
    ROUND(AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) * 100, 2) as taxa_atraso_geral,
    AVG(delay_hours) as atraso_medio_horas,
    COUNT(DISTINCT customer_id) as clientes_unicos,
    COUNT(DISTINCT carrier) as transportadoras_unicas
FROM delivery_analysis.deliveries
WHERE status = 'Entregue';



-- 2. PERFORMANCE POR TRANSPORTADORA
SELECT 
    carrier,
    COUNT(*) as total_entregas,
    ROUND(AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) * 100, 2) as taxa_atraso,
    ROUND(AVG(delay_hours), 2) as atraso_medio_horas,
    ROUND(AVG(delivery_duration), 2) as duracao_media_entrega
FROM delivery_analysis.deliveries
WHERE status = 'Entregue'
GROUP BY carrier
ORDER BY taxa_atraso ASC;



-- 3. CLIENTES COM MAIOR TAXA DE ATRASO
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.total_deliveries,
    ROUND(c.delay_rate * 100, 2) as taxa_atraso_percentual,
    c.avg_delay_hours,
    c.monthly_spend_avg
FROM delivery_analysis.customers c
WHERE c.total_deliveries >= 3
ORDER BY c.delay_rate DESC
LIMIT 10;


-- 4. ANÁLISE TEMPORAL
SELECT 
    order_day_of_week,
    order_month,
    COUNT(*) as total_entregas,
    ROUND(AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) * 100, 2) as taxa_atraso,
    AVG(delay_hours) as atraso_medio_horas
FROM delivery_analysis.deliveries
GROUP BY order_day_of_week, order_month
ORDER BY order_month, 
         CASE order_day_of_week
             WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
             WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
             WHEN 'Sunday' THEN 7
         END;


-- 5. ROTAS COM PROBLEMAS
SELECT 
    origin_city,
    destination_city,
    COUNT(*) as total_entregas,
    SUM(CASE WHEN is_delayed THEN 1 ELSE 0 END) as entregas_atrasadas,
    ROUND(AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) * 100, 2) as taxa_atraso,
    ROUND(AVG(delay_hours), 2) as atraso_medio_horas,
    MAX(delay_hours) as maior_atraso_horas,
    ROUND(AVG(delivery_duration), 2) as duracao_media_entrega,
    CASE 
        WHEN COUNT(*) = 1 THEN 'Poucos dados'
        WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Dados moderados' 
        ELSE 'Dados suficientes'
    END as confiabilidade_metrica,
    -- Análise adicional: tendência de melhora/piora
    CASE 
        WHEN AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) > 0.5 THEN 'CRÍTICO'
        WHEN AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) > 0.3 THEN 'ALTO RISCO'
        WHEN AVG(CASE WHEN is_delayed THEN 1 ELSE 0 END) > 0.1 THEN 'MODERADO'
        ELSE 'BAIXO RISCO'
    END as nivel_risco
FROM delivery_analysis.deliveries
WHERE status = 'Entregue'
GROUP BY origin_city, destination_city
HAVING COUNT(*) >= 1  -- Inclui todas as rotas
ORDER BY taxa_atraso DESC, total_entregas DESC
LIMIT 10;


-- 6. ANÁLISE DE COORTE: Performance mensal por tempo de cliente
WITH cohort_analysis AS (
    SELECT 
        c.customer_id,
        DATE_TRUNC('month', c.registration_date) AS cohort_month,
        DATE_TRUNC('month', d.order_date) AS order_month,
        (EXTRACT(YEAR FROM AGE(d.order_date, c.registration_date)) * 12 
         + EXTRACT(MONTH FROM AGE(d.order_date, c.registration_date)))::int AS months_since_registration,
        COUNT(d.delivery_id) AS deliveries,
        AVG(CASE WHEN d.is_delayed THEN 1.0 ELSE 0.0 END)::numeric AS delay_rate
    FROM delivery_analysis.customers c
    JOIN delivery_analysis.deliveries d 
        ON c.customer_id = d.customer_id
    WHERE d.status = 'Entregue'
    GROUP BY 
        c.customer_id,
        DATE_TRUNC('month', c.registration_date),
        DATE_TRUNC('month', d.order_date),
        months_since_registration
)
SELECT 
    cohort_month,
    months_since_registration,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(AVG(delay_rate) * 100, 2) AS avg_delay_rate,
    SUM(deliveries) AS total_deliveries
FROM cohort_analysis
GROUP BY cohort_month, months_since_registration
ORDER BY cohort_month, months_since_registration;



-- 7. PIVOT TABLE: Taxa de atraso por transportadora e segmento de cliente (COM COALESCE)
SELECT 
    carrier as Transportadora,
    COALESCE(ROUND(AVG(CASE WHEN c.customer_segment = 'Small' AND d.is_delayed THEN 1.0 
                            WHEN c.customer_segment = 'Small' THEN 0.0 
                            ELSE NULL END) * 100, 2), 0) as Small,
    COALESCE(ROUND(AVG(CASE WHEN c.customer_segment = 'Medium' AND d.is_delayed THEN 1.0 
                            WHEN c.customer_segment = 'Medium' THEN 0.0 
                            ELSE NULL END) * 100, 2), 0) as Medium,
    COALESCE(ROUND(AVG(CASE WHEN c.customer_segment = 'Enterprise' AND d.is_delayed THEN 1.0 
                            WHEN c.customer_segment = 'Enterprise' THEN 0.0 
                            ELSE NULL END) * 100, 2), 0) as Enterprise,
    ROUND(AVG(CASE WHEN d.is_delayed THEN 1.0 ELSE 0.0 END) * 100, 2) as Total,
    COUNT(*) as Total_Entregas,
    -- Contagem por segmento para debug
    COUNT(CASE WHEN c.customer_segment = 'Small' THEN 1 END) as Count_Small,
    COUNT(CASE WHEN c.customer_segment = 'Medium' THEN 1 END) as Count_Medium,
    COUNT(CASE WHEN c.customer_segment = 'Enterprise' THEN 1 END) as Count_Enterprise
FROM delivery_analysis.deliveries d
JOIN delivery_analysis.customers c ON d.customer_id = c.customer_id
WHERE d.status = 'Entregue'
GROUP BY carrier
ORDER BY Total DESC;


-- 8. PIVOT TABLE: Performance detalhada por transportadora e segmento
SELECT 
    carrier as "Transportadora",
    
    -- Taxas de Atraso por Segmento
    COALESCE(ROUND(
        SUM(CASE WHEN c.customer_segment = 'Small' AND d.is_delayed THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN c.customer_segment = 'Small' THEN 1 END), 0), 2
    ), 0) as "Small_Taxa_Atraso",
    
    COALESCE(ROUND(
        SUM(CASE WHEN c.customer_segment = 'Medium' AND d.is_delayed THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN c.customer_segment = 'Medium' THEN 1 END), 0), 2
    ), 0) as "Medium_Taxa_Atraso",
    
    COALESCE(ROUND(
        SUM(CASE WHEN c.customer_segment = 'Enterprise' AND d.is_delayed THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN c.customer_segment = 'Enterprise' THEN 1 END), 0), 2
    ), 0) as "Enterprise_Taxa_Atraso",
    
    -- Taxa Total
    ROUND(
        SUM(CASE WHEN d.is_delayed THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) as "Total_Taxa_Atraso",
    
    -- Volumes e Distribuição
    COUNT(*) as "Total_Entregas",
    COUNT(CASE WHEN c.customer_segment = 'Small' THEN 1 END) as "Qtd_Small",
    COUNT(CASE WHEN c.customer_segment = 'Medium' THEN 1 END) as "Qtd_Medium",
    COUNT(CASE WHEN c.customer_segment = 'Enterprise' THEN 1 END) as "Qtd_Enterprise",
    
    -- Distribuição Percentual
    ROUND(COUNT(CASE WHEN c.customer_segment = 'Small' THEN 1 END) * 100.0 / COUNT(*), 1) as "Pct_Small",
    ROUND(COUNT(CASE WHEN c.customer_segment = 'Medium' THEN 1 END) * 100.0 / COUNT(*), 1) as "Pct_Medium",
    ROUND(COUNT(CASE WHEN c.customer_segment = 'Enterprise' THEN 1 END) * 100.0 / COUNT(*), 1) as "Pct_Enterprise",
    
    -- Métricas Adicionais de Performance
    ROUND(AVG(d.delay_hours), 2) as "Atraso_Medio_Horas",
    ROUND(AVG(d.delivery_duration), 2) as "Duracao_Media_Entrega",
    MAX(d.delay_hours) as "Maior_Atraso_Horas"
    
FROM delivery_analysis.deliveries d
JOIN delivery_analysis.customers c ON d.customer_id = c.customer_id
WHERE d.status = 'Entregue'
GROUP BY carrier
ORDER BY "Total_Taxa_Atraso" DESC, "Total_Entregas" DESC;



-- 9. ANÁLISE DE SAZONALIDADE: Performance por dia da semana e mês
WITH seasonal_analysis AS (
    SELECT 
        EXTRACT(DOW FROM order_date) as day_of_week,
        EXTRACT(MONTH FROM order_date) as month,
        order_date,
        COUNT(*) as total_deliveries,
        AVG(CASE WHEN is_delayed THEN 1.0 ELSE 0.0 END) as delay_rate,
        AVG(delay_hours) as avg_delay_hours,
        AVG(delivery_duration) as avg_delivery_duration
    FROM delivery_analysis.deliveries
    WHERE status = 'Entregue'
    GROUP BY day_of_week, month, order_date
)
SELECT 
    day_of_week,
    CASE day_of_week 
        WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda' WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta' WHEN 4 THEN 'Quinta' WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END as dia_semana,
    month,
    COUNT(DISTINCT order_date) as dias_amostrados,
    ROUND(AVG(delay_rate) * 100, 2) as taxa_atraso_media,
    ROUND(AVG(avg_delay_hours), 2) as atraso_horas_medio,
    ROUND(AVG(avg_delivery_duration), 2) as duracao_entrega_media
FROM seasonal_analysis
GROUP BY day_of_week, month
ORDER BY month, day_of_week;



-- 10. WINDOW FUNCTIONS: Ranking de clientes dentro de cada segmento
WITH customer_rankings AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.total_deliveries,
        ROUND(c.delay_rate * 100, 2) as taxa_atraso,
        c.avg_delay_hours,
        c.monthly_spend_avg,
        RANK() OVER (PARTITION BY c.customer_segment ORDER BY c.delay_rate DESC) as rank_pior_desempenho,
        RANK() OVER (PARTITION BY c.customer_segment ORDER BY c.monthly_spend_avg DESC) as rank_maior_gasto,
        PERCENT_RANK() OVER (PARTITION BY c.customer_segment ORDER BY c.delay_rate) as percentil_desempenho
    FROM delivery_analysis.customers c
    WHERE c.total_deliveries >= 3
)
SELECT 
    customer_id,
    customer_name,
    customer_segment,
    total_deliveries,
    taxa_atraso,
    avg_delay_hours,
    monthly_spend_avg,
    rank_pior_desempenho,
    rank_maior_gasto,
    -- CORREÇÃO: Converter para numeric antes de usar ROUND
    ROUND((percentil_desempenho * 100)::numeric, 2) as percentil_desempenho_pct
FROM customer_rankings
ORDER BY customer_segment, rank_pior_desempenho
LIMIT 15;



-- 11. ANÁLISE DE SEGMENTAÇÃO RFM (Recência, Frequência, Valor)
WITH rfm_analysis AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        -- Recência: Dias desde última entrega
        COALESCE(EXTRACT(DAYS FROM (NOW() - MAX(d.order_date))), 90) as recencia,
        -- Frequência: Total de entregas
        c.total_deliveries as frequencia,
        -- Valor: Gasto mensal médio
        c.monthly_spend_avg as valor,
        -- Segmentação RFM
        NTILE(3) OVER (ORDER BY COALESCE(EXTRACT(DAYS FROM (NOW() - MAX(d.order_date))), 90) DESC) as r_score,
        NTILE(3) OVER (ORDER BY c.total_deliveries) as f_score,
        NTILE(3) OVER (ORDER BY c.monthly_spend_avg) as m_score
    FROM delivery_analysis.customers c
    LEFT JOIN delivery_analysis.deliveries d ON c.customer_id = d.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.total_deliveries, c.monthly_spend_avg
)
SELECT 
    r_score::TEXT || f_score::TEXT || m_score::TEXT as rfm_segment,  -- CONVERTENDO PARA TEXTO
    CASE 
        WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN ' Clientes Premium'
        WHEN r_score = 3 AND f_score >= 2 THEN ' Clientes Fieis'
        WHEN m_score = 3 THEN ' Clientes de Alto Valor'
        WHEN r_score = 1 THEN ' Clientes Inativos'
        ELSE ' Clientes Regulares'
    END as segmento_cliente,
    COUNT(*) as total_clientes,
    ROUND(AVG(recencia), 2) as recencia_media,
    ROUND(AVG(frequencia), 2) as frequencia_media,
    ROUND(AVG(valor), 2) as valor_medio
FROM rfm_analysis
GROUP BY r_score, f_score, m_score
ORDER BY r_score DESC, f_score DESC, m_score DESC;



-- 12. QUAL ROTAS CLIENTES USAM DEPOIS DE OUTRAS: Análise de sequência
WITH route_sequences AS (
    SELECT 
        customer_id,
        origin_city || ' -> ' || destination_city as rota_atual,
        LEAD(origin_city || ' -> ' || destination_city) OVER (
            PARTITION BY customer_id ORDER BY order_date
        ) as proxima_rota,
        order_date
    FROM delivery_analysis.deliveries
    WHERE status = 'Entregue'
),
sequence_analysis AS (
    SELECT 
        rota_atual,
        proxima_rota,
        COUNT(*) as total_sequencias,
        COUNT(DISTINCT customer_id) as clientes_unicos
    FROM route_sequences
    WHERE proxima_rota IS NOT NULL
    GROUP BY rota_atual, proxima_rota
)
SELECT 
    rota_atual as "Rota Inicial",
    proxima_rota as "Próxima Rota",
    total_sequencias as "Total de Sequências",
    clientes_unicos as "Clientes Únicos",
    ROUND(total_sequencias * 100.0 / clientes_unicos, 2) as "Frequência por Cliente",
    ROUND(clientes_unicos * 100.0 / (
        SELECT COUNT(DISTINCT customer_id) FROM delivery_analysis.deliveries
    ), 2) as "Penetração no Mercado %"
FROM sequence_analysis
WHERE clientes_unicos >= 1
ORDER BY total_sequencias DESC, clientes_unicos DESC
LIMIT 20;



-- 13. CLIENTES QUE USAM DIFERENTES ROTAS
WITH customer_route_variety AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT origin_city || ' -> ' || destination_city) as rotas_unicas,
        COUNT(*) as total_entregas,
        ARRAY_AGG(DISTINCT origin_city || ' -> ' || destination_city) as rotas_utilizadas
    FROM delivery_analysis.deliveries
    WHERE status = 'Entregue'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT origin_city || ' -> ' || destination_city) > 1
)
SELECT 
    crv.customer_id,
    c.customer_name,
    c.customer_segment,
    crv.rotas_unicas as "Quantidade de Rotas Diferentes",
    crv.total_entregas as "Total de Entregas",
    crv.rotas_utilizadas as "Rotas Utilizadas",
    ROUND(crv.rotas_unicas * 100.0 / crv.total_entregas, 2) as "Diversidade de Rotas %"
FROM customer_route_variety crv
JOIN delivery_analysis.customers c ON crv.customer_id = c.customer_id
ORDER BY crv.rotas_unicas DESC, crv.total_entregas DESC
LIMIT 15;



-- 14. ANÁLISE DE VALOR VITALÍCIO DO CLIENTE (LTV)
WITH customer_lifetime_value AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.registration_date,
        COUNT(d.delivery_id) as total_entregas_vida,
        SUM(c.monthly_spend_avg) / 3 as gasto_total_estimado, -- Aproximação
        EXTRACT(MONTH FROM AGE(NOW(), c.registration_date)) as meses_cliente,
        CASE 
            WHEN COUNT(d.delivery_id) = 0 THEN 0
            ELSE (SUM(c.monthly_spend_avg) / 3) / EXTRACT(MONTH FROM AGE(NOW(), c.registration_date))
        END as ltv_mensal,
        RANK() OVER (ORDER BY (SUM(c.monthly_spend_avg) / 3) DESC) as rank_ltv
    FROM delivery_analysis.customers c
    LEFT JOIN delivery_analysis.deliveries d ON c.customer_id = d.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment, c.registration_date
)
SELECT 
    customer_segment as segmento,
    COUNT(*) as total_clientes,
    ROUND(AVG(ltv_mensal), 2) as ltv_mensal_medio,
    ROUND(SUM(gasto_total_estimado), 2) as valor_total_segmento,
    ROUND(AVG(meses_cliente), 2) as tempo_relacionamento_medio,
    ROUND(AVG(total_entregas_vida), 2) as entregas_media_vida
FROM customer_lifetime_value
GROUP BY customer_segment
ORDER BY ltv_mensal_medio DESC;



