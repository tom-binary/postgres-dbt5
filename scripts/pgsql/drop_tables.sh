#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002 Mark Wong & Open Source Development Lab, Inc.
#
# 2006 Rilson Nascimento

DIR=`dirname $0`
. ${DIR}/pgsql_profile || exit 1

# Drop tables and domains

${PSQL} -d ${DBNAME} -c "DROP TABLE ACCOUNT_PERMISSION CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE CUSTOMER CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE CUSTOMER_ACCOUNT CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE CUSTOMER_TAXRATE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE HOLDING CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE HOLDING_HISTORY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE HOLDING_SUMMARY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE WATCH_ITEM CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE WATCH_LIST CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE BROKER CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE CASH_TRANSACTION CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE CHARGE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE COMMISSION_RATE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE SETTLEMENT CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE TRADE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE TRADE_HISTORY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE TRADE_REQUEST CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE TRADE_TYPE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE COMPANY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE COMPANY_COMPETITOR CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE DAILY_MARKET CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE EXCHANGE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE FINANCIAL CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE INDUSTRY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE LAST_TRADE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE NEWS_ITEM CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE NEWS_XREF CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE SECTOR CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE SECURITY CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE ADDRESS CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE STATUS_TYPE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE TAXRATE CASCADE;"
${PSQL} -d ${DBNAME} -c "DROP TABLE ZIP_CODE CASCADE;"

${PSQL} -d ${DBNAME} -c "DROP DOMAIN S_COUNT_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN IDENT_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN TRADE_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN BALANCE_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN S_PRICE_T"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN S_QTY_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN VALUE_T;"
${PSQL} -d ${DBNAME} -c "DROP DOMAIN FIN_AGG_T;"