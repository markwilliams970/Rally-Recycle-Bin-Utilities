# Copyright 2002-2013 Rally Software Development Corp. All Rights Reserved.
#
# This script is open source and is provided on an as-is basis. Rally provides
# no official support for nor guarantee of the functionality, usability, or
# effectiveness of this code, nor its suitability for any application that
# an end-user might have in mind. Use at your own risk: user assumes any and
# all risk associated with use and implementation of this script in his or
# her own environment.

# Usage: ruby rally_empty_recycle_bin.rb
# Specify the User-Defined variables below. Script will iterate through all items in
# Rally Recycle bin for specified Workspace, and prompt the user to confirm
# permanent deletion of the item of interest.

require 'rally_api'

$my_base_url       = "https://rally1.rallydev.com/slm"
$my_username       = "user@company.com"
$my_password       = "password"
$my_workspace      = "My Workspace"
$wsapi_version     = "1.43"

# Make no edits below this line!!
# =================================

#Setting custom headers
$headers                            = RallyAPI::CustomHttpHeader.new()
$headers.name                       = "Rally Empty Recycle Bin"
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

  # Query for all recycle bin items
  recycle_bin_query = RallyAPI::RallyQuery.new()
  recycle_bin_query.type = :recyclebin
  recycle_bin_query.fetch = true

  recycle_bin_query_results = @rally.find(recycle_bin_query)

  number_recycle_bin_items = recycle_bin_query_results.total_result_count

  if number_recycle_bin_items == 0
    puts "No items found in Recycle Bin. Exiting."
    exit
  end

  puts "Found #{number_recycle_bin_items} items in Recycle Bin for possible deletion."
  puts "Start processing deletions..."

# Loop through matching artifacts and delete them. Prompt user
# for each deletion.

  number_processed = 0
  number_deleted = 0
  affirmative_answer = "y"

  recycle_bin_query_results.each do | this_recycle_bin_item |

    number_processed += 1
    puts "Processing deletion for item #{number_processed} of #{number_recycle_bin_items}."

    item_formatted_id = this_recycle_bin_item["ID"]
    item_name = this_recycle_bin_item["Name"]
    item_type = this_recycle_bin_item["Type"]
    puts "Deleting Item #{item_formatted_id}, #{item_type}: #{item_name}..."
    puts this_recycle_bin_item["_ref"]
    really_delete = [(print "Really delete? [N/y]:"), gets.rstrip][1]

    if really_delete.downcase == affirmative_answer then
      begin
        delete_result = @rally.delete(this_recycle_bin_item["_ref"])
        puts "DELETED #{item_formatted_id}: #{item_name}"
        puts delete_result
        number_deleted += 1
      rescue => ex
        puts "Error occurred trying to delete: #{item_formatted_id}: #{item_name}"
        puts ex.backtrace
      end
    else
      puts "Did NOT delete #{item_formatted_id}: #{item_name}."
    end
  end

  puts
  puts "Processed deleteion attempts a total of #{number_deleted} items from the Recycle Bin."
  puts "Complete!"

end