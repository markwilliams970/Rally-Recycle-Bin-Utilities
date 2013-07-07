#!/bin/bash

# Copyright 2002-2013 Rally Software Development Corp. All Rights Reserved.
#
# This script is open source and is provided on an as-is basis. Rally provides
# no official support for nor guarantee of the functionality, usability, or
# effectiveness of this code, nor its suitability for any application that
# an end-user might have in mind. Use at your own risk: user assumes any and
# all risk associated with use and implementation of this script in his or
# her own environment.

#############################
# IMPORTANT!! PLEASE READ!! #
#############################
#
# Note: Recycle Bin items cannot be restored using Rally's REST webservices API
# This curl script is intended to provide a more convenient means of
# restoring an item with a known ObjectID and Formatted ID from the
# Rally Recycle Bin, without having to navigate through the Rally Recycle Bin
# UI (which frequently contains thousands of items), in order to find the
# item and restore via the UI.

# This script uses an un-documented and un-supported restore endpoint that is
# intended to be accessed from a web browser client. The endpoint used by
# this script is subject to change and as a result this script could break
# with no prior notice.

# In addition, because it does not use an official webservices endpoint,
# the script cannot ascertain the success/failure of the restore attempt
# from the server response. Thus you will need to look in the Rally UI
# to confirm the success/failure of the restore attempt.

###########################################
# USER ENVIRONMENT VARIABLES              #
###########################################

# Rally Server URL
RALLY_URL="https://rally1.rallydev.com"

# Rally credentials
# NOTE: User must be a Subscription or Workspace Administrator in order
# to restore items from the Recycle Bin.
RALLY_USERNAME="user@company.com"
RALLY_PASSWORD="t0p\$3cr3t"

# NOTE ON USE OF SPECIAL CHARACTERS IN PASSWORD
# If your password contains characters such as $ that
# have meaning to the shell, you'll need to escape them in the
# environment variable. I.E. if your password is "P@$$word", then
# the password variable should be set as follows:
# RALLY_PASSWORD="P@\$\$word"

# Object ID's for Rally Project, and OID of Recycle Bin Item to be restored
# Recycle Bin Entry OIDs may be easily obtained using this utility:
# https://github.com/markwilliams970/Rally-Recycle-Bin-Utilities/blob/master/rally_recyclebin_report.rb

PROJECT_OID="12345678910"
RESTORE_OID="10987654321"
RESTORE_FORMATTED_ID="TC123"

# NOTE: RESTORE_FORMATTED_ID is not used except as an output descriptor
# in this script. Its value is not used or needed for the actual
# restore attempt.

#########################################
# DO NOT MAKE CHANGES BELOW THIS LINE!! #
#########################################

# Obtain session cookie
echo "Authenticating with Rally - obtaining Session Cookie"
echo "Using Rally UserID: ${RALLY_USERNAME}"
echo "===================================================="
echo

curl -u "${RALLY_USERNAME}:${RALLY_PASSWORD}" "${RALLY_URL}/slm/webservice/v2.0/security/authorize" -c authcookie.txt

# Attempting Restore
printf "\n\n"
echo "Connecting to Rally - Attempting Restore of Recycle Bin Item:"
echo "Recycle Bin Item ObjectID: ${RESTORE_OID}"
echo "===================================================="
printf "\n\n"

# Strip out Rally hostname
RALLY_HOST=`echo ${RALLY_URL} | awk -F "/" '{print $3}'`

# Form Restore URL
RESTORE_URL="${RALLY_URL}/slm/recyclebin/restore.sp?cpoid=${PROJECT_OID}&projectScopeUp=true&projectScopeDown=true&_slug=/recyclebin"

curl ${RESTORE_URL} \
	-b authcookie.txt \
	-H "Origin: ${RALLY_URL}" \
	-H "Accept-Encoding: gzip,deflate,sdch" \
	-H "Host: ${RALLY_HOST}" \
	-H "Accept-Language: en-US,en;q=0.8" \
	-H "X-Requested-By: Rally" \
	-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
	-H "Accept: */*" \
	-H "Referer: ${RALLY_URL}/" \
	-H "X-Requested-With: XMLHttpRequest" \
	-H "Connection: keep-alive" \
	--data "oid=${RESTORE_OID}" \
	> /dev/null

# Attempt complete. Notify and cleanup.
printf "\n\n"
echo "Restore attempt complete. Check Rally for Item: ${RESTORE_FORMATTED_ID}"
echo "to verify successful restoration." 
printf "\n\n"

# Delete Session Cookie
echo "Removing Session Cookie file: authcookie.txt"
echo "Cleaning up temp file."
rm ./authcookie.txt

# Complete!
echo "Finished!"
