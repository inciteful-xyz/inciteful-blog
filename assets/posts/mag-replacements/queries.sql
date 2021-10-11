SELECT 
	COUNT(*) AS Total, 
	SUM(lens_found) AS Len_Found, 
	SUM(ss_found) AS ss_found, 
	SUM(incite_found) AS incite_found, 
	SUM(lens_cits) AS lens_cits, 
	SUM(ss_cits) AS ss_cits, 
	SUM(incite_cits) AS incite_cits, 
	SUM(lens_refs) AS lens_refs, 
	SUM(ss_refs) AS ss_refs, 
	SUM(incite_refs) AS incite_refs, 
	SUM(CASE WHEN lens_found AND NOT ss_found THEN 1 ELSE 0 END) AS lens_only, 
	SUM(CASE WHEN ss_found AND NOT lens_found THEN 1 ELSE 0 END) AS ss_only, 
	SUM(CASE WHEN lens_found AND incite_cits > lens_cits THEN 1 ELSE 0 END) AS incite_more_cits_than_lens, 
	SUM(CASE WHEN lens_found AND incite_cits < lens_cits THEN 1 ELSE 0 END) AS lens_more_cits_than_incite, 
	SUM(CASE WHEN lens_found AND incite_refs > lens_refs THEN 1 ELSE 0 END) AS incite_more_refs_than_lens, 
	SUM(CASE WHEN lens_found AND incite_refs < lens_refs THEN 1 ELSE 0 END) AS lens_more_refs_than_incite, 
	SUM(CASE WHEN ss_found AND incite_cits > ss_cits THEN 1 ELSE 0 END) AS incite_more_cits_than_ss, 
	SUM(CASE WHEN ss_found AND incite_cits < ss_cits THEN 1 ELSE 0 END) AS ss_more_cits_than_incite, 
	SUM(CASE WHEN ss_found AND incite_refs > ss_refs THEN 1 ELSE 0 END) AS incite_more_refs_than_ss, 
	SUM(CASE WHEN ss_found AND incite_refs < ss_refs THEN 1 ELSE 0 END) AS ss_more_refs_than_incite, 
	SUM(CASE WHEN lens_found AND ss_found AND lens_cits > ss_cits THEN 1 ELSE 0 END) AS lens_more_cits_than_ss, 
	SUM(CASE WHEN lens_found AND ss_found AND lens_cits < ss_cits THEN 1 ELSE 0 END) AS ss_more_cits_than_lens, 
	SUM(CASE WHEN lens_found AND ss_found AND lens_refs > ss_refs THEN 1 ELSE 0 END) AS lens_more_refs_than_ss, 
	SUM(CASE WHEN lens_found AND ss_found AND lens_refs < ss_refs THEN 1 ELSE 0 END) AS ss_more_refs_than_lens 
FROM compare 
-- WHERE incite_found -- Incite found
-- WHERE lens_found -- lens found
-- WHERE ss_found -- ss found
WHERE incite_cits + incite_refs + lens_refs + lens_cits + ss_cits + ss_refs > 0 AND doctype <> 'Patent'-- Has Cit Data
;

SELECT 
	docType, COUNT(*), SUM(incite_cits) AS incite_cits, SUM(incite_refs) AS incite_refs 
FROM compare 
WHERE incite_found 
GROUP BY docType;

SELECT 
	docType, COUNT(*), SUM(incite_cits) AS incite_cits, SUM(incite_refs) AS incite_refs 
FROM compare 
WHERE incite_found AND NOT lens_found 
GROUP BY docType;

SELECT 
	docType, COUNT(*), SUM(incite_cits) AS incite_cits, SUM(incite_refs) AS incite_refs 
FROM compare 
WHERE incite_found AND NOT ss_found 
GROUP BY docType;

SELECT strftime('%Y', createdDate), COUNT(*) 
FROM compare 
WHERE incite_found 
AND not lens_found 
AND doctype <> 'Patent'
GROUP BY 1;

SELECT * 
FROM compare 
WHERE incite_found 
AND not lens_found 
AND doctype <> 'Patent';

SELECT title, id
FROM compare 
WHERE incite_found 
AND not ss_found 
AND doctype <> 'Patent'
AND incite_cits + incite_refs > 0
AND year < 2021;

