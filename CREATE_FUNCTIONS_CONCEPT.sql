-- Create missing concept "Functions and Graphing" in Domain 2
INSERT INTO concepts (domain_id, name) 
SELECT d.id, 'Functions and Graphing'
FROM domains d 
JOIN certifications c ON d.certification_id = c.id 
WHERE c.test_code = '902' AND d.name = 'Patterns and Algebra'
ON CONFLICT (domain_id, name) DO NOTHING;
