-- Identified the TABLE [ rating, `ORDER`] and applied join
SELECT CUME_DIST FROM `order` AS o
INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID;

-- Fetch only relevant COLUMNS
SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID;

-- Join between supplier_pricing and test TABLE
SELECT * FROM supplier_pricing AS sp
INNER JOIN (
    SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
    INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
) AS test ON test.PRICING_ID = sp.PRICING_ID;

-- Taking relevant COLUMNS only
SELECT sp.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS FROM supplier_pricing AS sp
INNER JOIN (
    SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
    INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
) AS test ON test.PRICING_ID = sp.PRICING_ID;

-- Taking Average RAT_RATSTARS AS Average
SELECT test2.SUPP_ID, SUM(test2.RAT_RATSTARS) / COUNT(test2.RAT_RATSTARS) AS Average FROM
(
    SELECT sp.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS FROM supplier_pricing AS sp
    INNER JOIN (
        SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
        INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
    ) AS test ON test.PRICING_ID = sp.PRICING_ID
) AS test2
GROUP BY test2.SUPP_ID;

-- Apply Join between final and supplier TABLE
SELECT final.SUPP_ID, supplier.SUPP_Name, final.Average FROM
(
    SELECT test2.SUPP_ID, SUM(test2.RAT_RATSTARS) / COUNT(test2.RAT_RATSTARS) AS Average FROM
    (
        SELECT sp.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS FROM supplier_pricing AS sp
        INNER JOIN (
            SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
            INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
        ) AS test ON test.PRICING_ID = sp.PRICING_ID
    ) AS test2
    GROUP BY test2.SUPP_ID
) AS final
INNER JOIN supplier ON supplier.SUPP_ID = final.SUPP_ID;

-- Apply CASE
SELECT
    report.SUPP_ID,
    report.SUPP_Name,
    report.Average,
    CASE
        WHEN report.Average = 5 THEN 'Excellent Service'
        WHEN report.Average > 4 THEN 'Good Service'
        WHEN report.Average > 2 THEN 'Average Service'
        ELSE 'Poor Service'
    END AS Type_of_Service
FROM (
    SELECT final.SUPP_ID, supplier.SUPP_Name, final.Average FROM (
        SELECT test2.SUPP_ID, SUM(test2.RAT_RATSTARS) / COUNT(test2.RAT_RATSTARS) AS Average FROM (
            SELECT sp.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS FROM supplier_pricing AS sp
            INNER JOIN (
                SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
                INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
            ) AS test ON test.PRICING_ID = sp.PRICING_ID
        ) AS test2
        GROUP BY test2.SUPP_ID
    ) AS final
    INNER JOIN supplier ON final.SUPP_ID = supplier.SUPP_ID
) AS report;

-- Create Stored PROCEDURE
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `SUP_RATTINGS`()
BEGIN
    SELECT
        report.SUPP_ID,
        report.SUPP_Name,
        report.Average,
        CASE
            WHEN report.Average = 5 THEN 'Excellent Service'
            WHEN report.Average > 4 THEN 'Good Service'
            WHEN report.Average > 2 THEN 'Average Service'
            ELSE 'Poor Service'
        END AS Type_of_Service
    FROM (
        SELECT final.SUPP_ID, supplier.SUPP_Name, final.Average FROM (
            SELECT test2.SUPP_ID, SUM(test2.RAT_RATSTARS) / COUNT(test2.RAT_RATSTARS) AS Average FROM (
                SELECT sp.SUPP_ID, test.ORD_ID, test.RAT_RATSTARS FROM supplier_pricing AS sp
                INNER JOIN (
                    SELECT o.PRICING_ID, r.ORD_ID, r.RAT_RATSTARS FROM `order` AS o
                    INNER JOIN rating AS r ON o.ORD_ID = r.ORD_ID
                ) AS test ON test.PRICING_ID = sp.PRICING_ID
            ) AS test2
            GROUP BY test2.SUPP_ID
        ) AS final
        INNER JOIN supplier ON final.SUPP_ID = supplier.SUPP_ID
    ) AS report;
END //
DELIMITER ;

-- Calling Stored PROCEDURE
CALL ecom_db.SUP_RATTINGS();
