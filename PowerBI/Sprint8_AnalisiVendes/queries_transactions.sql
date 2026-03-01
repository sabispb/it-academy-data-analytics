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
