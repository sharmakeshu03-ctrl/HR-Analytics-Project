-- HR Analytics Project - SQL Queries on Cleaned Data

-- Q1. Department-wise average Engagement Score aur employee count nikalo.
SELECT DepartmentType,
       COUNT(DepartmentType) AS employee_count,
       AVG("Engagement Score") AS avg_eng_score
FROM df
GROUP BY DepartmentType

-- Q2. Un departments ko find karo jinka average Engagement Score 3 se greater hai.
SELECT DepartmentType,
       AVG("Engagement Score") AS avg_eng_score
FROM df
GROUP BY DepartmentType
HAVING avg_eng_score > 3

-- Q3. Har Performance Score category ka average Engagement Score nikalo, highest se lowest order mein.
SELECT "Performance Score",
       AVG("Engagement Score") AS avg_engagement
FROM df
GROUP BY "Performance Score"
ORDER BY avg_engagement DESC

-- Q4. Un employees ko find karo jinka Engagement Score >= 4 hai aur Performance Score = 'Exceeds' hai.
SELECT FirstName,
       LastName,
       "Performance Score",
       "Engagement Score"
FROM df
WHERE "Engagement Score" >= 4
  AND "Performance Score" = 'Exceeds'

-- Q5. Un DepartmentType ko find karo jinka average Satisfaction Score 3 se greater hai.
SELECT DepartmentType,
       AVG("Satisfaction Score") AS avg_satisfaction_score
FROM df
GROUP BY DepartmentType
HAVING avg_satisfaction_score > 3

-- Q6. Har Training Type ka average Training Cost nikalo, highest se lowest order mein.
SELECT "Training Type",
       AVG("Training Cost") AS Avg_cost
FROM df
GROUP BY "Training Type"
ORDER BY Avg_cost DESC

-- Q7. Un Performance Score categories ko find karo jinka average Training Cost 500 se greater hai.
SELECT "Performance Score",
       AVG("Training Cost") AS Avg_cost
FROM df
GROUP BY "Performance Score"
HAVING Avg_cost > 500

-- Q8. Har DepartmentType ka maximum Training Cost nikalo aur sirf wahi departments dikhao jinka maximum cost 1000 se greater hai.
SELECT DepartmentType,
       MAX("Training Cost") AS Max_cost
FROM df
GROUP BY DepartmentType
HAVING Max_cost > 1000

-- Q9. CASE statement se Engagement Score ko High, Medium aur Low categories mein divide karo.
SELECT FirstName,
       LastName,
       "Engagement Score",
       CASE
           WHEN "Engagement Score" >= 4 THEN 'High'
           WHEN "Engagement Score" >= 3 THEN 'Medium'
           WHEN "Engagement Score" < 3 THEN 'Low'
       END AS Engagement_Level
FROM df

-- Q10. High, Medium aur Low Engagement categories mein kitne employees hain, count karo.
SELECT
    CASE
        WHEN "Engagement Score" >= 4 THEN 'High'
        WHEN "Engagement Score" >= 3 THEN 'Medium'
        WHEN "Engagement Score" < 3 THEN 'Low'
    END AS Engagement_Level,
    COUNT(*) AS total_count
FROM df
GROUP BY
    CASE
        WHEN "Engagement Score" >= 4 THEN 'High'
        WHEN "Engagement Score" >= 3 THEN 'Medium'
        WHEN "Engagement Score" < 3 THEN 'Low'
    END

-- Q11. Har DepartmentType mein Active employees ka count nikalo.
SELECT DepartmentType,
       COUNT(EmployeeStatus) AS total_employee
FROM df
WHERE EmployeeStatus = 'Active'
GROUP BY DepartmentType

-- Q12. Un employees ko find karo jinka Training Cost unke own DepartmentType ke average Training Cost se greater hai.
WITH Avg_cost AS
(
    SELECT DepartmentType,
           AVG("Training Cost") AS avg_training
    FROM df
    GROUP BY DepartmentType
)
SELECT
    b.FirstName,
    b.LastName,
    b.DepartmentType,
    b."Training Cost"
FROM Avg_cost a
JOIN df b
    ON a.DepartmentType = b.DepartmentType
WHERE b."Training Cost" > a.avg_training

-- Q13. Har DepartmentType mein highest Training Cost wale employee(s) find karo.
WITH Max_cost AS
(
    SELECT DepartmentType,
           MAX("Training Cost") AS Max_training
    FROM df
    GROUP BY DepartmentType
)
SELECT
    b.FirstName,
    b.LastName,
    b.DepartmentType,
    b."Training Cost"
FROM Max_cost a
JOIN df b
    ON a.DepartmentType = b.DepartmentType
   AND a.Max_training = b."Training Cost"

-- Q14. Har Performance Score category ka total employee count aur average Training Cost nikalo; average cost ke descending order mein sort karo.
SELECT
    "Performance Score",
    AVG("Training Cost") AS Avg_cost,
    COUNT("Performance Score") AS total_employees
FROM df
GROUP BY "Performance Score"
ORDER BY Avg_cost DESC

-- Q15. CASE statement se Performance Score ko Top Performer, Good Performer aur Needs Attention categories mein divide karo.
SELECT
    FirstName,
    LastName,
    "Performance Score",
    CASE
        WHEN "Performance Score" = 'Exceeds'
            THEN 'Top Performer'
        WHEN "Performance Score" = 'Fully Meets'
            THEN 'Good Performer'
        WHEN "Performance Score" = 'Needs Improvement'
            THEN 'Needs Attention'
    END AS Performance_Category
FROM df

-- Q16. High performers find karo: Performance Score = 'Exceeds' aur Engagement Score >= 4.
SELECT
    FirstName,
    LastName,
    "Performance Score",
    "Engagement Score",
    DepartmentType
FROM df
WHERE "Performance Score" = 'Exceeds'
  AND "Engagement Score" >= 4

-- Q17. Har DepartmentType ke andar employees ko Training Cost ke basis par highest se lowest RANK karo.
SELECT
    FirstName,
    LastName,
    "Training Cost",
    DepartmentType,
    RANK() OVER(
        PARTITION BY DepartmentType
        ORDER BY "Training Cost" DESC
    ) AS rank
FROM df

-- Q18. Har DepartmentType mein 2nd highest Training Cost wale employee(s) find karo.
WITH ranked AS
(
    SELECT
        DepartmentType,
        FirstName,
        LastName,
        "Training Cost",
        RANK() OVER(
            PARTITION BY DepartmentType
            ORDER BY "Training Cost" DESC
        ) AS rank
    FROM df
)
SELECT
    FirstName,
    LastName,
    DepartmentType,
    "Training Cost",
    rank
FROM ranked
WHERE rank = 2

-- Q19. Har DepartmentType mein highest Training Cost wale employee ko ROW_NUMBER() ka use karke find karo.
WITH ranked AS
(
    SELECT
        DepartmentType,
        FirstName,
        LastName,
        "Training Cost",
        ROW_NUMBER() OVER(
            PARTITION BY DepartmentType
            ORDER BY "Training Cost" DESC
        ) AS row_num
    FROM df
)
SELECT
    FirstName,
    LastName,
    DepartmentType,
    "Training Cost",
    row_num
FROM ranked
WHERE row_num = 1

-- Q20. Har DepartmentType mein highest Training Cost wale employee ke saath department ka average Training Cost bhi show karo.
WITH ranked AS
(
    SELECT
        FirstName,
        LastName,
        DepartmentType,
        "Training Cost",
        AVG("Training Cost") OVER(
            PARTITION BY DepartmentType
        ) AS avg_cost,
        ROW_NUMBER() OVER(
            PARTITION BY DepartmentType
            ORDER BY "Training Cost" DESC
        ) AS row_num
    FROM df
)
SELECT
    FirstName,
    LastName,
    DepartmentType,
    "Training Cost",
    avg_cost
FROM ranked
WHERE row_num = 1

