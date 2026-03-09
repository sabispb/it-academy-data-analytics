USE s4_transactions;

SELECT id, transaction_date, declined
FROM transactions
WHERE year(transaction_date) BETWEEN '2020' AND '2026'
ORDER BY transaction_date DESC;

SELECT declined, COUNT(declined)
FROM transactions
GROUP BY declined;

SELECT id, transaction_date, declined
FROM transactions
WHERE declined = '1'
ORDER BY transaction_date ASC;

SELECT YEAR(transaction_date), declined, COUNT(id)
FROM transactions
WHERE declined = '1'
GROUP BY YEAR(transaction_date)
ORDER BY YEAR(transaction_date) ASC;


SELECT COUNT(product_id), YEAR(transaction_date)
FROM transaction_product tp
JOIN transactions t ON tp.transaction_id = t.id
GROUP BY YEAR(transaction_date);

SELECT MIN(price), MAX(price)
FROM products p
JOIN transaction_product tp ON p.id = tp.product_id
JOIN transactions t ON tp.transaction_id = t.id
GROUP BY YEAR(transaction_date);

SELECT ROUND(SUM(amount), 2), YEAR(transaction_date) AS year, country
FROM transactions t
JOIN all_users u ON u.id = t.user_id
WHERE country IN ('Poland','France')
	AND YEAR(transaction_date) IN ('2020','2024')
GROUP BY YEAR(transaction_date), country
order by YEAR(transaction_date);

SELECT COUNT(p.id), YEAR(transaction_date), transaction_id
FROM products p
JOIN transaction_product tp ON p.id = tp.product_id
JOIN transactions t ON t.id = tp.transaction_id
-- ORDER BY transaction_id
GROUP BY transaction_id;
