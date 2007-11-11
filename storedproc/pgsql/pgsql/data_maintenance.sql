/*
 * 2006 Rilson Nascimento
 *
 * Data Maintenance transaction
 * -------------------------
 * The intent of the transaction is to modify data tables that would not
 * otherwise be written to by the benchmark.
 * 
 *
 * Based on TPC-E Standard Specification Draft Revision 0.32.2e Clause 3.3.11.
 */

/*
 * Frame 1
 * Update a table
 */

CREATE OR REPLACE FUNCTION DataMaintenanceFrame1 (
						IN add_flag	smallint,
						IN cust_id	IDENT_T,
						IN comp_id 	IDENT_T,
						IN day_of_month	smallint,
						IN symbol	char(15),
						IN table_name	char(18),
						IN tax_id 	char(4)) RETURNS smallint AS $$
DECLARE
	-- variables
	rowcount	integer;
	custacct_id	IDENT_T;
	acl		char(4);

	line2		varchar;
	addr_id		IDENT_T;

	sprate		char(4);

	email2		varchar;
	len		integer;
	lenMindspring	integer;

	tax_rate	numeric(6,5);

	tax_name	varchar;
	name_len	integer;
	rate_len	integer;
	pos		integer;

	wlist_id	IDENT_T;
	wi_symbol	char(15);
	last_wl_id	IDENT_T;
BEGIN
	
	IF table_name = 'ACCOUNT_PERMISSION' THEN

		-- ACCOUNT_PERMISSION
		-- Update the AP_ACL to “1111” or “0011” in rows for a
		-- customer account of c_id.

		rowcount = 0;
		custacct_id = 0;
		acl = NULL;

		SELECT	count(*)
		INTO	rowcount
		FROM	ACCOUNT_PERMISSION
		WHERE	AP_CA_ID in (SELECT CA_ID
					FROM	CUSTOMER_ACCOUNT
					WHERE	CA_C_ID = cust_id);

		-- If we found a row to update, update it.

		IF rowcount != 0 THEN
			SELECT	AP_ACL,
				AP_CA_ID
			INTO	acl,
				custacct_id
			FROM	ACCOUNT_PERMISSION
			WHERE	AP_CA_ID = (SELECT min(AP_CA_ID)
						FROM	ACCOUNT_PERMISSION
						WHERE	AP_CA_ID in (SELECT CA_ID
									FROM	CUSTOMER_ACCOUNT
									WHERE	CA_C_ID = cust_id))
			LIMIT 1;

			IF acl != '1111' THEN
				UPDATE	ACCOUNT_PERMISSION
				SET	AP_ACL = '1111'
				WHERE	AP_CA_ID = custacct_id;
			ELSE -- ACL is “1111” change it to '0011'
				UPDATE	ACCOUNT_PERMISSION
				SET	AP_ACL = '0011'
				WHERE	AP_CA_ID = custacct_id;
			END IF;
		END IF;

	ELSIF table_name = 'ADDRESS' THEN
		-- ADDRESS
		-- Change AD_LINE2 in the ADDRESS table for
		-- the CUSTOMER with C_ID of c_id.

		line2 = NULL;
		addr_id = 0;

		SELECT	AD_LINE2,
			AD_ID
		INTO	line2,
			addr_id 
		FROM	ADDRESS,
			CUSTOMER
		WHERE	AD_ID = C_AD_ID AND
			C_ID = cust_id;

		IF line2 != 'Apt. 10C' THEN
			UPDATE	ADDRESS
			SET	AD_LINE2 = 'Apt. 10C'
			WHERE	AD_ID = addr_id;
		ELSE
			UPDATE	ADDRESS
			SET	AD_LINE2 = 'Apt. 22'
			WHERE	AD_ID = addr_id;
		END IF;

	ELSIF table_name = 'COMPANY' THEN
		-- COMPANY
		-- Update a row in the COMPANY table identified
		-- by co_id, set the company’s Standard and Poor
		-- credit rating to “ABA” or to “AAA”.

		sprate = NULL;

		SELECT	CO_SP_RATE
		INTO	sprate
		FROM	COMPANY
		WHERE	CO_ID = comp_id;

		IF sprate != 'ABA' THEN
			UPDATE	COMPANY
			SET	CO_SP_RATE = 'ABA'
			WHERE	CO_ID = comp_id;
		ELSE
			UPDATE	COMPANY
			SET	CO_SP_RATE = 'AAA'
			WHERE	CO_ID = comp_id;
		END IF;

	ELSIF table_name = 'CUSTOMER' THEN
		-- CUSTOMER
		-- Update the second email address of a CUSTOMER
		-- identified by c_id. Set the ISP part of the customer’s
		-- second email address to “@mindspring.com”
		-- or “@earthlink.com”.

		email2 = NULL;
		len = 0;
		lenMindspring = char_length('@mindspring.com');

		SELECT	C_EMAIL_2
		INTO	email2
		FROM	CUSTOMER
		WHERE	C_ID = cust_id;

		len = char_length(email2);
		len = len - lenMindspring;

		IF len > 0 AND substring(email2 from len + 1 for lenMindspring) = '@mindspring.com' THEN
		-- (strcmp(substr(email2,len-lenMindspring,lenMindspring),'@mindspring.com') == 0) THEN
			UPDATE	CUSTOMER
			SET	C_EMAIL_2 = substring(C_EMAIL_2 from 1 for position('@' in C_EMAIL_2)) || 'earthlink.com'
			-- SET	C_EMAIL_2 = substring(C_EMAIL_2, 1, charindex(“@”,C_EMAIL_2) ) + 'earthlink.com'
			WHERE	C_ID = cust_id;
		ELSE /* set to @mindspring.com */
			UPDATE	CUSTOMER
			SET	C_EMAIL_2 = substring(C_EMAIL_2 from 1 for position('@' in C_EMAIL_2) ) || 'mindspring.com'
			-- SET	C_EMAIL_2 = substring(C_EMAIL_2, 1,charindex(“@”,C_EMAIL_2) ) + 'mindspring.com'
			WHERE	C_ID = cust_id;
		END IF;

	ELSIF table_name = 'CUSTOMER_TAXRATE' THEN
		-- CUSTOMER_TAXRATE
		-- A tax rate identified by “999” will be inserted into
		-- the CUSTOMER_TAXRATE table for the CUSTOMER identified
		-- by c_id.If the customer already has the “999” tax
		-- rate, the tax Rate will be deleted. To preserve for
		-- foreign key integrity The “999” tax rate must exist
		-- in the TAXRATE table.

		rowcount = 0;
		tax_rate = 0;

		-- Flip the special tax rate between 11% and 13%
		SELECT	TX_RATE
		INTO	tax_rate
		FROM	TAXRATE
		WHERE	TX_ID = '999';

		IF tax_rate = 0.11 THEN
			UPDATE	TAXRATE
			SET	TX_RATE = 0.13
			WHERE	TX_ID = '999';
		ELSE
			UPDATE	TAXRATE
			SET	TX_RATE = 0.11
			WHERE	TX_ID = '999';
		END IF;

		SELECT	count(*)
		INTO	rowcount
		FROM	CUSTOMER_TAXRATE
		WHERE	CX_C_ID = cust_id AND
			CX_TX_ID = '999';

		IF rowcount = 0 THEN
			/* No 999 tax rate for customer, */
			/* add one for them */
			INSERT INTO	CUSTOMER_TAXRATE (CX_TX_ID, CX_C_ID)
			VALUES		('999', cust_id);
		ELSE
			-- There was a “999” tax rate for
			-- this, customer delete it.
			DELETE FROM	CUSTOMER_TAXRATE
			WHERE		CX_TX_ID = '999' AND
					CX_C_ID = cust_id;
		END IF;

	ELSIF table_name = 'DAILY_MARKET' THEN
		--- DAILY_MARKET
		--- A security symbol, a day in the month and a
		--- random number of zero or one, are passed into
		--- the Data Maintenance function, when table_name
		--- is DAILY_MARKET. The DM_VOL column in the DAILY_MARKET
		--- table will be updated by adding 1 or subtracting 1.
		--- The rows to be updated are those for the security
		--- whose symbol was passed in, and forthat day in the
		--- month that was passed in. If the random number passed
		--- in was one, 1 is added to DM_VOL otherwise 1 is
		--- subtracted from DM_VOL.

		IF add_flag = 1 THEN
			UPDATE	DAILY_MARKET
			SET	DM_VOL = DM_VOL + 1
			WHERE	DM_S_SYMB = symbol AND
				substring (DM_DATE from 6 for 2)::smallint = day_of_month;
				-- substring ((convert(char(8),DM_DATE,3),1,2) = day_of_month;
		ELSE
			UPDATE	DAILY_MARKET
			SET	DM_VOL = DM_VOL - 1
			WHERE	DM_S_SYMB = symbol AND
				substring (DM_DATE from 6 for 2)::smallint = day_of_month;
				-- substring(convert(char(8),DM_DATE,3),1,2) = day_of_month;
		END IF;

	ELSIF table_name = 'EXCHANGE' THEN
		--- EXCHANGE
		--- Other than the table_name, no additional
		--- parameters are used when the table_name is EXCHANGE.
		--- There are only four rows in the EXCHANGE table. Every
		--- row will have its EX_DESC updated. If EX_DESC does not
		--- already end with “LAST UPDATED “ and a date and time,
		--- that string will be appended to EX_DESC. Otherwise the
		--- date and time at the end of EX_DESC will be updated
		--- to the current date and time.

		rowcount = 0;

		SELECT	count(*)
		INTO	rowcount
		FROM	EXCHANGE
		WHERE	EX_DESC like '%LAST UPDATED%';

		IF rowcount = 0 THEN
			UPDATE	EXCHANGE
			SET	EX_DESC = EX_DESC || ' LAST UPDATED ' || now();
		ELSE
			UPDATE	EXCHANGE
			SET	EX_DESC = substring(EX_DESC from 1 for char_length(EX_DESC) - char_length(now())) || now();
			--SET	EX_DESC = substring(EX_DESC,1,len(EX_DESC)-len(getdatetime())) + getdatetime();
		END IF;

	ELSIF table_name = 'FINANCIAL' THEN
		-- FINANCIAL
		-- Update the FINANCIAL table for a company identified by
		-- co_id. That company’s FI_QTR_START_DATEs will be
		-- updated to the second of the month or to the first of
		-- the month if the dates were already the second of the
		-- month.

		rowcount = 0;

		SELECT	count(*)
		INTO	rowcount
		FROM	FINANCIAL
		WHERE	FI_CO_ID = comp_id AND
			substring(FI_QTR_START_DATE from 9 for 2)::smallint = 1;
			-- substring(convert(char(8),FI_QTR_START_DATE,2),7,2) = “01”;

		IF rowcount > 0 THEN
			UPDATE	FINANCIAL
			SET	FI_QTR_START_DATE = FI_QTR_START_DATE + interval '1 day'
			WHERE	FI_CO_ID = comp_id;
		ELSE
			UPDATE	FINANCIAL
			SET	FI_QTR_START_DATE = FI_QTR_START_DATE - interval '1 day'
			WHERE	FI_CO_ID = comp_id;
		END IF;

	ELSIF table_name = 'NEWS_ITEM' THEN
		-- NEWS_ITEM
		-- Update the news items for a specified company.
		-- Change the NI_DTS by 1 day.

		UPDATE	NEWS_ITEM
		SET	NI_DTS = NI_DTS + interval '1 day'
		WHERE	NI_ID = (SELECT NX_NI_ID
					FROM	NEWS_XREF
					WHERE	NX_CO_ID = comp_id LIMIT 1);

	ELSIF table_name = 'SECURITY' THEN
		-- SECURITY
		-- Update a security identified symbol, increment
		-- S_EXCH_DATE by 1 day.

		UPDATE	SECURITY
		SET	S_EXCH_DATE = S_EXCH_DATE + interval '1 day'
		WHERE	S_SYMB = symbol;

	ELSIF table_name = 'TAXRATE' THEN
		-- TAXRATE
		-- Update a TAXRATE identified by tx_id. The tax rate’s
		-- TX_NAME Will be updated to end with the word “rate”,
		-- or the word“rate” will be removed from the end of the
		-- TX_NAME if TX_NAME already ends with the word “rate”.

		tax_name = NULL;
		name_len = 0;
		rate_len = 0;
		pos = 1;	-- [Rilson] changed from 0 to 1

		SELECT	TX_NAME
		INTO	tax_name
		FROM	TAXRATE
		WHERE	TX_ID = tax_id;

		IF tax_name IS NOT NULL THEN
			name_len = char_length(tax_name);
			rate_len = char_length(' rate');
			pos = name_len - rate_len + 1; -- [Rilson] added +1

			IF pos < 0 THEN
				pos = 1; -- [Rilson] changed from 0 to 1
			END IF;

			-- TX_NAME does not already end with “ rate”

			IF substring(tax_name from pos for rate_len) != ' rate' THEN
			--IF strcmp(substring(tx_name,pos,rate_len),” rate”) != 0 THEN
				UPDATE	TAXRATE
				SET	TX_NAME = TX_NAME || ' rate'
				WHERE	TX_NAME not like '% rate' AND
					TX_ID = tax_id;
			ELSE
				-- row already has a TX_NAME that ends “ rate”
				UPDATE	TAXRATE
				SET	TX_NAME = substring(TX_NAME from 1 for char_length(TX_NAME) - char_length(' rate'))
				--SET	TX_NAME = substring(TX_NAME,1,len(TX_NAME)-len(“ rate”))
				WHERE	TX_ID = tax_id;
			END IF;
		END IF;

	ELSIF table_name = 'WATCH_ITEM' THEN
		-- WATCH_ITEM
		-- A WATCH_LIST containing the WATCH_ITEMs with security
		-- symbols “AA”, “ZAPS” and “ZONS” will be added for the
		-- customer identified by c_id, if the customer does not
		-- already have a watch list with those items. If the
		-- customer already has a watch list with those items,
		-- the watch list will be deleted.

		wlist_id = 0;
		wi_symbol = NULL;
		last_wl_id = 0;

		-- If the CUSTOMER identified by c_id has a watch
		-- list with “AA”, “ZAPS”, “ZONS”, it would have the
		-- highest WL_ID of that customer’s watch lists.

		SELECT	max(WL_ID)
		INTO	wlist_id
		FROM	WATCH_LIST
		WHERE	WL_C_ID = cust_id;

		IF wlist_id IS NOT NULL THEN
			-- See if the watch list has items other then
			-- “AA”, “ZAPS”, “ZONS” in it
			SELECT	max(WI_S_SYMB)
			INTO	wi_symbol
			FROM	WATCH_ITEM
			WHERE	WI_WL_ID = wlist_id AND
				WI_S_SYMB NOT IN ('AA','ZAPS','ZONS');

			IF wi_symbol IS NOT NULL THEN
				-- Customer does not have “AA”, “ZAPS”, “ZONS”
				-- watch list. Find the last watch list
				-- identifier used.
	
				SELECT	max(WL_ID)
				INTO	last_wl_id
				FROM	WATCH_LIST;

				INSERT INTO	WATCH_LIST (WL_ID, WL_C_ID)
				VALUES		(last_wl_id + 1, cust_id);

				INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
				VALUES		(last_wl_id + 1, 'AA');

				INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
				VALUES		(last_wl_id + 1, 'ZAPS');

				INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
				VALUES		(last_wl_id + 1, 'ZONS');
			ELSE
				-- Customer already has the “AA”, “ZAPS”,”ZONS”
				-- watch list, so delete it, and delete all the
				-- other customers “AA” “ZAPS”, “ZONS” watch lists,
				-- so that WL_ID never gets too big.

				SELECT	max(WL_ID)
				INTO	wlist_id
				FROM	WATCH_LIST
				WHERE	WL_ID in (SELECT distinct(WI_WL_ID)
							FROM	WATCH_ITEM
							WHERE	WI_S_SYMB != 'AA' AND
								WI_S_SYMB != 'ZAPS' AND
								WI_S_SYMB != 'ZONS'
							GROUP BY WI_WL_ID);

				DELETE FROM	WATCH_ITEM
				WHERE		WI_WL_ID > wlist_id;

				DELETE FROM	WATCH_LIST
				WHERE		WL_ID > wlist_id;
			END IF;
		ELSE
			-- Customer has no watch lists, so add the
			-- “AA”, “ZAPS”, “ZONS” watch list

			SELECT	max(WL_ID)
			INTO	last_wl_id
			FROM	WATCH_LIST;

			INSERT INTO	WATCH_LIST (WL_ID, WL_C_ID)
			VALUES		(last_wl_id + 1, cust_id);

			INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
			VALUES		(last_wl_id + 1, 'AA');

			INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
			VALUES		(last_wl_id + 1, 'ZAPS');

			INSERT INTO	WATCH_ITEM (WI_WL_ID, WI_S_SYMB)
			VALUES		(last_wl_id + 1, 'ZONS');
		END IF;
	END IF;

	RETURN 0;
END;
$$ LANGUAGE 'plpgsql';