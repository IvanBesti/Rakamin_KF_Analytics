WITH 
  -- Subquery untuk menghitung data dasar transaksi
  transaction_details AS (
    SELECT 
      tr.transaction_id AS trans_id,
      tr.date AS trans_date,
      tr.branch_id,
      kc.branch_name,
      kc.kota,
      kc.provinsi,
      kc.rating AS branch_rating,
      tr.customer_name AS customer,
      tr.product_id,
      pr.product_name AS prod_name,
      pr.price AS actual_price,
      tr.discount_percentage AS discount_pct,
      -- Menghitung persentase laba menggunakan CASE statement
      CASE
        WHEN pr.price <= 50000 THEN 0.10
        WHEN pr.price BETWEEN 50001 AND 100000 THEN 0.15
        WHEN pr.price BETWEEN 100001 AND 300000 THEN 0.20
        WHEN pr.price BETWEEN 300001 AND 500000 THEN 0.25
        ELSE 0.30
      END AS gross_margin_pct,
      -- Menghitung harga setelah diskon (nett_sales)
      pr.price * (1 - tr.discount_percentage) AS nett_sales,
      tr.rating AS transaction_rating
    FROM 
      `kimia_farma.kf_final_transaction` AS tr
    JOIN 
      `kimia_farma.kf_kantor_cabang` AS kc 
      ON tr.branch_id = kc.branch_id
    JOIN 
      `kimia_farma.kf_product` AS pr 
      ON tr.product_id = pr.product_id
  ),
  
  -- Subquery untuk menghitung laba kotor, biaya produksi, dan laba bersih
  profit_analysis AS (
    SELECT
      td.*,
      -- Menghitung laba kotor berdasarkan harga produk dan persentase laba
      td.actual_price * td.gross_margin_pct AS gross_profit,
      -- Menghitung biaya produksi sebagai selisih antara harga produk dan laba kotor
      td.actual_price - (td.actual_price * td.gross_margin_pct) AS production_cost,
      -- Menghitung laba bersih sebagai selisih antara penjualan bersih dan biaya produksi
      td.nett_sales - (td.actual_price - (td.actual_price * td.gross_margin_pct)) AS nett_profit
    FROM 
      transaction_details AS td
  )

-- Memilih kolom-kolom untuk output akhir
SELECT 
  trans_id AS transaction_id,
  trans_date AS date,
  branch_id,
  branch_name,
  kota AS city,
  provinsi AS province,
  branch_rating AS rating_cabang,
  customer AS customer_name,
  product_id AS prod_id,
  prod_name AS product_name,
  actual_price,
  discount_pct AS discount_percentage,
  gross_margin_pct AS persentase_gross_laba,
  nett_sales,
  nett_profit,
  transaction_rating AS rating_transaksi
FROM 
  profit_analysis
ORDER BY 
  trans_date ASC;