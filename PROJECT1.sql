SELECT
    COUNT(*)
FROM
    PROJECT1_LIBRARY_BRANCH_LOAD

SELECT AUTHRO FROM PROJECT1_BOOKS_LOAD

SELECT ADDRESS FROM PROJECT1_BORROWERS_LOAD

SELECT COUNT(*) FROM (SELECT DISTINCT b.ISBN10, bc.BOOK_ID
FROM 
PROJECT1_BOOKS_LOAD B,PROJECT1_BOOK_COPIES_LOAD bc
where b.ISBN10 = bc.BOOK_ID)

select * from PROJECT1_BOOKS_LOAD

desc BOOK

ALTER TABLE PROJECT1_BOOKS_LOAD RENAME COLUMN AUTHRO TO AUTHOR
COMMIT

--Book Table--
CREATE TABLE PROJECT1_BOOK (
    ISBN VARCHAR2(4000) PRIMARY KEY,
    TITLE VARCHAR2(4000)
);

--Book Authors Table--
CREATE TABLE PROJECT1_BOOK_AUTHORS (
    AUTHOR_ID NUMBER(38) NOT NULL,
    ISBN VARCHAR2(4000) NOT NULL,
    FOREIGN KEY (AUTHOR_ID) REFERENCES PROJECT1_AUTHORS(AUTHOR_ID),
    FOREIGN KEY (ISBN) REFERENCES PROJECT1_BOOK(ISBN)
);

ALTER TABLE PROJECT1_BOOK_AUTHORS ADD (
    CONSTRAINT BOOK_AUTHORS_PK PRIMARY KEY ( AUTHOR_ID,
                                             ISBN )
);

--Authors Table--
CREATE TABLE PROJECT1_AUTHORS (
    AUTHOR_ID INT GENERATED ALWAYS AS IDENTITY,
    NAME VARCHAR2(4000),
    PRIMARY KEY(AUTHOR_ID)
);

--Library Branch Table--
CREATE TABLE PROJECT1_LIBRARY_BRANCH(
    BRANCH_ID INT PRIMARY KEY,
    BRANCH_NAME VARCHAR2(4000),
    ADDRESS VARCHAR2(4000)
);

--Book Copies Table--
CREATE TABLE PROJECT1_BOOK_COPIES (
    BOOK_ID INT GENERATED ALWAYS AS IDENTITY,
    ISBN VARCHAR2(4000) NOT NULL,
    BRANCH_ID INT NOT NULL,
    FOREIGN KEY (ISBN) REFERENCES PROJECT1_BOOK (ISBN),
    FOREIGN KEY (BRANCH_ID) REFERENCES PROJECT1_LIBRARY_BRANCH (BRANCH_ID),
    PRIMARY KEY(BOOK_ID)
);

ALTER TABLE PROJECT1_BOOK_COPIES ADD (NO_OF_COPIES INT DEFAULT NULL) ;

--Borrower Table--
CREATE TABLE PROJECT1_BORROWER(
    CARD_NO VARCHAR2(4000) PRIMARY KEY,
    SSN VARCHAR2(4000) DEFAULT NULL,
    FNAME VARCHAR2(4000) DEFAULT NULL,
    LNAME VARCHAR2(4000) DEFAULT NULL,
    ADDRESS VARCHAR2(4000) DEFAULT NULL,
    PHONE VARCHAR2(4000) DEFAULT NULL
);

--Book Loans Table--
CREATE TABLE PROJECT1_BOOK_LOANS(
    LOAN_ID INT GENERATED ALWAYS AS IDENTITY,
    BOOK_ID INT NOT NULL,
    CARD_NO VARCHAR2(4000) NOT NULL,
    DATE_OUT DATE DEFAULT NULL,
    DUE_DATE DATE DEFAULT NULL,
    DATE_IN DATE DEFAULT NULL,
    FOREIGN KEY (BOOK_ID) REFERENCES PROJECT1_BOOK_COPIES(BOOK_ID),
    FOREIGN KEY (CARD_NO) REFERENCES PROJECT1_BORROWER(CARD_NO),
    PRIMARY KEY (LOAN_ID)
);

--Fines Table--
CREATE TABLE PROJECT1_FINES(
    LOAN_ID INT PRIMARY KEY,
    FINE_AMT FLOAT DEFAULT NULL,
    PAID FLOAT DEFAULT NULL,
    FOREIGN KEY (LOAN_ID) REFERENCES PROJECT1_BOOK_LOANS(LOAN_ID)
);

ALTER TABLE PROJECT1_FINES MODIFY PAID VARCHAR2(4000);

--Normalizing Tables--
--Borrowers Table--
ALTER TABLE PROJECT1_BORROWER DROP COLUMN ADDRESS;

ALTER TABLE PROJECT1_BORROWER ADD (
    STREET VARCHAR2(4000) DEFAULT NULL,
    CITY   VARCHAR2(4000) DEFAULT NULL,
    STATE  VARCHAR2(4000) DEFAULT NULL
);

--Inserting Data in Tables--

--Books Table--
INSERT INTO PROJECT1_BOOK (
    ISBN,
    TITLE
)
    SELECT
        ISBN10 AS ISBN,
        TITLE
    FROM
        PROJECT1_BOOKS_LOAD;

select COUNT(*) from PROJECT1_BOOK

--Book Authors--
INSERT INTO PROJECT1_BOOK_AUTHORS (
    AUTHOR_ID,
    ISBN
)
    SELECT
        PA.AUTHOR_ID,
        PBL.ISBN
    FROM
            (
            SELECT DISTINCT
                AUTHOR_NAME,
                ISBN
            FROM
                (
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) IS NOT NULL
                    UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) IS NOT NULL
                    UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) IS NOT NULL
                    UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) IS NOT NULL
                    UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) IS NOT NULL
                )
        ) PBL
        INNER JOIN PROJECT1_AUTHORS PA ON PA.NAME = PBL.AUTHOR_NAME;

select COUNT(*) from PROJECT1_BOOK_AUTHORS;

--Authors--
INSERT INTO PROJECT1_AUTHORS (NAME) SELECT DISTINCT AUTHOR_NAME
FROM
(
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) IS NOT NULL
);

select COUNT(AUTHOR_ID) from PROJECT1_AUTHORS GROUP BY AUTHOR_ID HAVING COUNT(AUTHOR_ID) > 1;

--Library Branch--
INSERT INTO PROJECT1_LIBRARY_BRANCH (
    BRANCH_ID,
    BRANCH_NAME,
    ADDRESS
)
    SELECT
        BRANCH_ID,
        BRANCH_NAME,
        ADDRESS
    FROM
        PROJECT1_LIBRARY_BRANCH_LOAD;

select COUNT(*) from PROJECT1_LIBRARY_BRANCH

--Book Copies--
INSERT INTO PROJECT1_BOOK_COPIES (
    ISBN,
    BRANCH_ID,
    NO_OF_COPIES
)
    SELECT
        BOOK_ID AS ISBN,
        BRANCH_ID,
        NO_OF_COPIES
    FROM
        PROJECT1_BOOK_COPIES_LOAD;

select * from PROJECT1_BOOK_COPIES

--Borrower--
INSERT INTO PROJECT1_BORROWER (
    CARD_NO,
    SSN,
    FNAME,
    LNAME,
    STREET,
    CITY,
    STATE,
    PHONE
)
    SELECT
        ID0000ID   AS CARD_NO,
        SSN,
        FIRST_NAME AS FNAME,
        LAST_NAME  AS LNAME,
        ADDRESS    AS STREET,
        CITY,
        STATE,
        PHONE
    FROM
        PROJECT1_BORROWERS_LOAD; SELECT
    COUNT(*)
FROM
    PROJECT1_BORROWER
SELECT
    COUNT(*)
FROM
    PROJECT1_BORROWER;

--Book Loans--    
INSERT INTO PROJECT1_BOOK_LOANS (
    BOOK_ID,
    CARD_NO
)
    SELECT
        BOOK_ID,
        CARD_NO
    FROM
        (
            WITH RAND_BORROWER1 AS (
                SELECT
                    ROWNUM ROW_ID,
                    CARD_NO
                FROM
                    (
                        SELECT
                            *
                        FROM
                            PROJECT1_BORROWER
                        WHERE
                            ROWNUM <= 200
                        ORDER BY
                            DBMS_RANDOM.RANDOM
                    )
            ), RAND_BORROWER2 AS (
                SELECT
                    ROWNUM ROW_ID,
                    CARD_NO
                FROM
                    (
                        SELECT
                            *
                        FROM
                            RAND_BORROWER1
                        ORDER BY
                            ROW_ID DESC
                    )
            )
            SELECT
                RB2.ROW_ID,
                RB2.CARD_NO
            FROM
                RAND_BORROWER2 RB2
            UNION ALL
            SELECT
                RB1.ROW_ID,
                RB1.CARD_NO
            FROM
                RAND_BORROWER1 RB1
        ) TEMP1
        LEFT JOIN (
            SELECT
                ROWNUM ROW_ID,
                BOOK_ID
            FROM
                (
                    WITH RAND_BOOKS AS (
                        SELECT
                            ROWNUM ROW_ID,
                            BOOK_ID
                        FROM
                            (
                                SELECT
                                    *
                                FROM
                                    PROJECT1_BOOK_COPIES
                                WHERE
                                    ROWNUM <= 100
                                ORDER BY
                                    DBMS_RANDOM.RANDOM
                            )
                    )
                    SELECT
                        *
                    FROM
                        RAND_BOOKS
                    UNION ALL
                    SELECT
                        *
                    FROM
                        RAND_BOOKS
                )
        ) TEMP2 ON TEMP1.ROW_ID = TEMP2.ROW_ID
    ORDER BY
        CARD_NO;

-----
MERGE INTO PROJECT1_BOOK_LOANS PBL
USING (
    SELECT
        ROWNUM ROW_ID,
        DATE_OUT,
        DATE_IN,
        DUE_DATE
    FROM
        (
            SELECT
                TEMP          AS DATE_OUT,
                DUE_DATE,
                DUE_DATE + 10 AS DATE_IN
            FROM
                (
                    SELECT
                        TEMP,
                        TEMP + 60 AS DUE_DATE
                    FROM
                        (
                            SELECT
                                TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2022-01-01', 'J'),
                                                                TO_CHAR(DATE '2022-10-30', 'J'))),
                                        'J') AS TEMP
                            FROM
                                DUAL
                            CONNECT BY
                                LEVEL <= 400
                        )
                )
            WHERE
                ROWNUM <= 200
            UNION ALL
            SELECT
                TEMP          AS DATE_OUT,
                DUE_DATE,
                DUE_DATE - 10 AS DATE_IN
            FROM
                (
                    SELECT
                        TEMP,
                        TEMP + 60 AS DUE_DATE
                    FROM
                        (
                            SELECT
                                TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2022-01-01', 'J'),
                                                                TO_CHAR(DATE '2022-10-30', 'J'))),
                                        'J') AS TEMP
                            FROM
                                DUAL
                            CONNECT BY
                                LEVEL <= 400
                        )
                )
            WHERE
                ROWNUM <= 200
        )
) TABLE_DATE ON ( PBL.LOAN_ID = TABLE_DATE.ROW_ID )
WHEN MATCHED THEN UPDATE
SET PBL.DATE_OUT = TABLE_DATE.DATE_OUT,
    PBL.DATE_IN = TABLE_DATE.DATE_IN,
    PBL.DUE_DATE = TABLE_DATE.DUE_DATE;


--------
INSERT INTO PROJECT1_FINES (
    LOAN_ID,
    FINE_AMT,
    PAID
)
    SELECT
        LOAN_ID,
        5   AS FINE_AMT,
        CASE
            WHEN MOD(LOAN_ID, 2) <> 0 THEN
                'YES'
            ELSE
                'NO'
        END AS PAID
    FROM
        (
            SELECT
                LOAN_ID,
                ROW_NUMBER()
                OVER(PARTITION BY CARD_NO
                     ORDER BY
                         CARD_NO
                ) AS RANK,
                CARD_NO,
                DUE_DATE,
                DATE_IN
            FROM
                PROJECT1_BOOK_LOANS
        ) TEMP
    WHERE
            TEMP.RANK = 2
        AND DATE_IN > DUE_DATE
            AND ROWNUM <= 50
    ORDER BY
        DBMS_RANDOM.RANDOM;


--Book Search--
WITH SEARCH AS (
    SELECT
        TEMP.BRANCH_ID,
        TEMP.ISBN,
        TITLE,
        NAME,
        CASE
            WHEN NO_OF_COPIES > 0 THEN
                'BOOKS ARE AVAILABLE'
            ELSE
                'BOOKS ARE NOT AVAILABLE'
        END AS AVAILIBILITY_STATUS
    FROM
             (
            SELECT
                BOOK_COPIES.ISBN AS ISBN,
                LIBRARY_BRANCH.BRANCH_ID,
                BOOK_COPIES.NO_OF_COPIES
            FROM
                     PROJECT1_BOOK_COPIES BOOK_COPIES
                INNER JOIN PROJECT1_LIBRARY_BRANCH LIBRARY_BRANCH ON LIBRARY_BRANCH.BRANCH_ID = BOOK_COPIES.BRANCH_ID
        ) TEMP
        INNER JOIN PROJECT1_BOOK         BOOK ON TEMP.ISBN = BOOK.ISBN
        INNER JOIN PROJECT1_BOOK_AUTHORS BOOK_AUTHORS ON TEMP.ISBN = BOOK_AUTHORS.ISBN
        INNER JOIN PROJECT1_AUTHORS      AUTHORS ON BOOK_AUTHORS.AUTHOR_ID = AUTHORS.AUTHOR_ID
)
SELECT
    *
FROM
    SEARCH
WHERE
    BRANCH_ID = &BRANCH_SEARCH
UNION ALL
SELECT
    *
FROM
    SEARCH
WHERE
    UPPER(TITLE) LIKE UPPER('%&Keyword%')
UNION ALL
SELECT
    *
FROM
    SEARCH
WHERE
    UPPER(NAME) LIKE UPPER('%&Keyword%');

--Reports--
--CITY WISE MONTHLY FINE--
SELECT
    B.CITY,
    SUM(F.FINE_AMT)  AS MONTHLY_TOTAL_FINE,
    TO_CHAR(TO_DATE(EXTRACT(MONTH FROM BL.DATE_IN), 'MM'), 'MONTH') AS MONTH_NAME
FROM
    PROJECT1_BOOK_LOANS BL
    INNER JOIN PROJECT1_FINES F ON BL.LOAN_ID = F.LOAN_ID
    INNER JOIN PROJECT1_BORROWER B ON B.CARD_NO = BL.CARD_NO
GROUP BY
    CITY,
    TO_CHAR(TO_DATE(EXTRACT(MONTH FROM BL.DATE_IN),'MM'),'MONTH');

--TOTAL FINE AMOUNT FOR EACH BORROWER--
SELECT
    B.FNAME,
    B.LNAME,
    TEMP.TOTAL_FINE_AMOUNT
FROM
    (
        SELECT
            BL.CARD_NO,
            SUM(F.FINE_AMT) AS TOTAL_FINE_AMOUNT
        FROM
            PROJECT1_BOOK_LOANS BL
            INNER JOIN PROJECT1_FINES F ON BL.LOAN_ID = F.LOAN_ID
        GROUP BY
            BL.CARD_NO
    ) TEMP
    INNER JOIN PROJECT1_BORROWER B ON TEMP.CARD_NO = B.CARD_NO 
    ORDER BY FNAME;

--Which city has maximum fine in the month of NOVEMBER
SELECT
    TEMP.CITY,
    TEMP.MONTHLY_TOTAL_FINE
FROM
    (
        SELECT
            B.CITY,
            SUM(F.FINE_AMT)  AS MONTHLY_TOTAL_FINE,
            EXTRACT (MONTH FROM DATE_IN) AS MONTH_NAME
        FROM
            PROJECT1_BOOK_LOANS BL
            INNER JOIN PROJECT1_FINES    F ON BL.LOAN_ID = F.LOAN_ID
            INNER JOIN PROJECT1_BORROWER B ON B.CARD_NO = BL.CARD_NO
        WHERE
            EXTRACT (MONTH FROM DATE_IN) = 11
        GROUP BY
            CITY,
            EXTRACT (MONTH FROM DATE_IN)
    ) TEMP 
    ORDER BY TEMP.MONTHLY_TOTAL_FINE DESC
    FETCH FIRST 1 ROW ONLY;



