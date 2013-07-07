Rally-Recycle-Bin-Utilities
===========================

rally_recyclebin_report.rb
==========================

Utility for Summarizing the ENTIRE contents of the Recycle Bin for a given Workspace

This script can be used to output a summary spreadsheet of all the items contained in the Recycle Bin,
including the following fields:

 - ID
 - ObjectID
 - DeletionDate
 - Name
 - DeletedBy
 - Type
 - WSAPI URL Ref to Recycle Bin Entry
 
 The results are output to a CSV output file called recyclebin.csv
 
rally_delete_recyclebin_items.rb
================================

This script will take as input a CSV file of the exact same field format as is output by the rally_recyclebin_report.rb script. Recommended workflow:

- Run the rally_recyclebin_report.rb script to provide the full Recycle bin summary
- Edit the resulting CSV in your favorite text editor, or in Excel
- Remove all entries _except_ for those you wish to delete
- Save the resulting file as recyclebin_todelete.csv (Default expected input file for the rally_delete_recyclebin_items.rb)
- Lastly, run the rally_delete_recyclebin_items.rb script, which will PERMANENTLY DELETE only those items specified in your input CSV
- You will be prompted to confirm each deletion attempt

rally_empty_recycle_bin.rb
================================
Script will iterate through _all_ items in Rally Recycle bin for specified Workspace and prompt the user to confirm permanent deletion of the item of interest.

 Requires:

 - Ruby 1.9.3 or higher
 - rally_api 0.9.2 or higher

restore_recylebin_item.sh
=========================
Bash/curl script that uses an un-supported and un-documented web endpoint
that makes it easier to restore a single Recycle Bin Item without having to
hunt for it via the Rally UI.

 Requires:

 - Bourne shell
 - curl
