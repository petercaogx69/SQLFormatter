SELECT
  a.contract_id,
  a.contract_code,
  a.contract_name,
  a.host_product_line,
  a.design_team,
  COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0) AS contract_amount_no_factoring,
  a.contract_signing_status,
  a.contract_date,
  a.contract_type,
  a.contract_follower,
  a.customer_id,
  a.customer_name,
  COALESCE(b.all_appoint_amount,0) AS all_appoint_amount,
  CASE
    WHEN (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0) = 0) OR COALESCE(b.all_appoint_amount,0) = 0 THEN 0
    ELSE ROUND(COALESCE(b.all_appoint_amount,0) / (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0)) * 100,2)
  END AS appoint_amount_percent,
  COALESCE(b.search_appoint_amount,0) AS search_appoint_amount,
  COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0) - COALESCE(b.all_appoint_amount,0) AS left_appoint_amount,
  COALESCE(c.all_invoice_amount,0) AS all_invoice_amount,
  CASE
    WHEN (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0) = 0) OR COALESCE(c.all_invoice_amount,0) = 0 THEN 0
    ELSE ROUND(COALESCE(c.all_invoice_amount,0) / (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0)) * 100,2)
  END AS invoice_amount_percent,
  COALESCE(c.search_invoice_amount,0) AS search_invoice_amount,
  COALESCE(d.all_borrow_money,0) AS all_borrow_money,
  CASE
    WHEN (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0) = 0) OR COALESCE(d.all_borrow_money,0) = 0 THEN 0
    ELSE ROUND(COALESCE(d.all_borrow_money,0) / (COALESCE(a.signing_money_sum,0) - COALESCE(a.not_contain_factoring_amount,0)) * 100,2)
  END AS borrow_money_percent,
  COALESCE(d.search_borrow_money,0) AS search_borrow_money,
  COALESCE(b.all_appoint_amount,0) - COALESCE(d.all_borrow_money,0) AS should_borrow_money
FROM
  contracts a
  LEFT JOIN (
    SELECT
      am.contract_id,
      SUM(
        CASE
          WHEN COALESCE(d.num,0) = 0 THEN ar.appoint_amount
          ELSE 0
        END) AS all_appoint_amount,
      SUM(
        CASE
          WHEN COALESCE(d.num,0) = 0 AND ar.record_date >= :start_date AND ar.record_date < :end_date THEN ar.appoint_amount
          ELSE 0
        END) AS search_appoint_amount
    FROM
      attachment_manage_records ar
      LEFT JOIN attachment_manages am  ON ar.attachment_manage_id = am.attachment_manage_id
      LEFT JOIN contracts c  ON am.contract_id = c.contract_id
      LEFT JOIN (
        SELECT
          attachment_manage_record_id,
          COUNT(1) AS num
        FROM
          sale_integral_changes
        WHERE
          status = 2
          AND delete_flag = 0
        GROUP BY
          attachment_manage_record_id
      )  AS d  ON ar.attachment_manage_record_id = d.attachment_manage_record_id
    WHERE
      am.contract_id = :contract_id
      AND c.contract_name LIKE :contract_name
      AND c.contract_code LIKE :contract_code
    GROUP BY
      am.contract_id
  )  AS b  ON a.contract_id = b.contract_id
  LEFT JOIN (
    SELECT
      i.contract_id,
      SUM(i.invoice_amount) AS all_invoice_amount,
      SUM(
        CASE
          WHEN i.invoice_date >= :start_date AND i.invoice_date < :end_date THEN i.invoice_amount
          ELSE 0
        END) AS search_invoice_amount
    FROM
      invoices i
      LEFT JOIN contracts c  ON i.contract_id = c.contract_id
    WHERE
      sign != 4
      AND sign != 3
      AND i.contract_id = :contract_id
      AND c.contract_name LIKE :contract_name
      AND c.contract_code LIKE :contract_code
    GROUP BY
      i.contract_id
  )  AS c  ON a.contract_id = c.contract_id
  LEFT JOIN (
    SELECT
      cp.contract_id,
      SUM(cp.borrow_money) AS all_borrow_money,
      SUM(
        CASE
          WHEN cp.happen_date >= :start_date AND cp.happen_date < :end_date THEN cp.borrow_money
          ELSE 0
        END) AS search_borrow_money
    FROM
      capitals cp
      LEFT JOIN contracts c  ON cp.contract_id = c.contract_id
    WHERE
      cp.contract_id = :contract_id
      AND c.contract_name LIKE :contract_name
      AND c.contract_code LIKE :contract_code
    GROUP BY
      cp.contract_id
  )  AS d  ON a.contract_id = d.contract_id
WHERE
  a.contract_id = :contract_id
  AND a.contract_code LIKE :contract_code
  AND a.contract_name LIKE :contract_name
  AND a.host_product_line = :host_product_line
  AND a.design_team = :design_team
  AND a.contract_signing_status = :contract_signing_status
  AND a.contract_follower = :contract_follower
  AND a.customer_name LIKE :customer_name
  AND a.customer_id = :customer_id
