# Copyright 2002-2013 Rally Software Development Corp. All Rights Reserved.
#
# This script is open source and is provided on an as-is basis. Rally provides
# no official support for nor guarantee of the functionality, usability, or
# effectiveness of this code, nor its suitability for any application that
# an end-user might have in mind. Use at your own risk: user assumes any and
# all risk associated with use and implementation of this script in his or
# her own environment.

# Usage: ruby rally_recyclebin_report.rb
# Specify the User-Defined variables below. Script will iterate through all items in
# Rally Recycle bin and summarize their properties

require 'rally_api'
require 'csv'

$my_base_url       = "https://rally1.rallydev.com/slm"
$my_username       = "user@company.com"
$my_password       = "password"
$my_workspace      = "My Workspace"
$wsapi_version     = "1.43"

$my_output_file         = "recyclebin.csv"
$recyclebin_fields      =  %w{FormattedID ObjectID DeletionDate Name DeletedBy Type Ref RestoreLink}

if $my_delim == nil then $my_delim = "," end

# Make no edits below this line!!
# =================================

#Setting custom headers
$headers                            = RallyAPI::CustomHttpHeader.new()
$headers.name                       = "Rally Recycle Bin Report"
$headers.vendor                     = "Rally Labs"
$headers.version                    = "0.50"

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

begin

  #==================== Make a connection to Rally ====================

  config                  = {:base_url => $my_base_url}
  config[:username]       = $my_username
  config[:password]       = $my_password
  config[:workspace]      = $my_workspace
  config[:version]        = $wsapi_version
  config[:headers]        = $headers

  @rally = RallyAPI::RallyRestJson.new(config)

  # Query for all Recycle Bin Items
  recycle_bin_query = RallyAPI::RallyQuery.new()
  recycle_bin_query.type = :recyclebin
  recycle_bin_query.fetch = true

  recycle_bin_query_results = @rally.find(recycle_bin_query)

  number_recycle_bin_items = recycle_bin_query_results.total_result_count

  if number_recycle_bin_items == 0
    puts "No items found in Recycle Bin. Exiting."
    exit
  end

  puts "Found #{number_recycle_bin_items} items in Recycle Bin for output to summary file."
  puts "Start processing items..."

  # Loop through matching artifacts and summarize them.

  # Output CSV header
  recyclebin_csv = CSV.open($my_output_file, "w", {:col_sep => $my_delim})
  recyclebin_csv << $recyclebin_fields

  # Loop through recycle bin entries and output them

  puts "Exporting recycle bin items to file: #{$my_output_file}."
  puts "Total Items to Export: #{number_recycle_bin_items}"

  exported_count = 0

  recycle_bin_query_results.each do | this_recycle_bin_item |

    data = []

    exported_count += 1

    item_id = this_recycle_bin_item["ID"]
    item_oid = this_recycle_bin_item["ObjectID"]
    item_deletion_date = this_recycle_bin_item["DeletionDate"]
    item_name = this_recycle_bin_item["Name"]
    item_deleted_by = this_recycle_bin_item["DeletedBy"]._refObjectName
    item_type = this_recycle_bin_item["Type"]
    item_ref = this_recycle_bin_item["_ref"]
    item_restore_link = "#{$my_base_url}/recyclebin/restore.sp?oid=#{item_oid}"

    data << item_id
    data << item_oid
    data << item_deletion_date
    data << item_name
    data << item_deleted_by
    data << item_type
    data << item_ref
    data << item_restore_link

    recyclebin_csv << CSV::Row.new($recyclebin_fields, data)

  end

  puts
  puts "Summarized a total of #{exported_count} items in the Recycle Bin."
  puts "Complete!"

end