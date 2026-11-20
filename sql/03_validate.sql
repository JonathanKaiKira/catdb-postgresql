SELECT count(*) AS cats FROM catdb.cats;

SELECT c.cat_code, COALESCE(sum(e.amount_clp), 0) AS total_clp
FROM catdb.cats AS c LEFT JOIN catdb.expenses AS e USING (cat_id)
GROUP BY c.cat_code ORDER BY c.cat_code;

SELECT c.cat_code, v.follow_up_on
FROM catdb.vet_visits AS v JOIN catdb.cats AS c USING (cat_id)
WHERE v.follow_up_on >= DATE '2030-05-15'
ORDER BY v.follow_up_on, c.cat_code;
