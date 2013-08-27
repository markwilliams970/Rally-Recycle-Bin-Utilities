# Copyright 2002-2013 Rally Software Development Corp. All Rights Reserved.
#
# This script is open source and is provided on an as-is basis. Rally provides
# no official support for nor guarantee of the functionality, usability, or
# effectiveness of this code, nor its suitability for any application that
# an end-user might have in mind. Use at your own risk: user assumes any and
# all risk associated with use and implementation of this script in his or
# her own environment.

# Usage: ruby rally_delete_recyclebin_items.rb
# Specify the User-Defined variables below. Script will iterate through all items in
# $filename          = "recyclebin_todelete.csv"
# and prompt the user to confirm permanent deletion of the item of interest.

require 'rally_api'
require 'csv'

$my_base_url       = "https://rally1.rallydev.com/slm"
$my_username       = "user@company.com"
$my_password       = "password"
$my_workspace      = "My Workspace"
$wsapi_version     = "1.43"

# File containing CSV list of items to delete from Recycle Bin
$filename          = "recyclebin_todelete.csv"

# Make no edits below this line!!
# =================================

#Setting custom headers
$headers                            = RallyAPI::CustomHttpHeader.new()
$headers.name                       = "Rally Delete Recycle Bin Items"
$headers.vendor                     = "Rally Labs"
$headers.version                    = "0.50"

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

def delete_recycle_bin_entry(header, row)
  
  affirmative_answer = "y"
  
  item_formatted_id               = row[header[0]].strip
  item_object_id                  = row[header[1]].strip
  item_deletion_date              = row[header[2]].strip
  item_name                       = row[header[3]].strip
  item_deleted_by                 = row[header[4]].strip
  item_type                       = row[header[5]].strip
  item_ref                        = row[header[6]].strip
  item_restore_url                = row[header[7]].strip

  this_recycle_bin_item = {}
  this_recycle_bin_item["ObjectID"] = item_object_id
  this_recycle_bin_item["_ref"] = item_ref
  
  puts "Deleting Item #{item_formatted_id}, #{item_type}: #{item_name}..."
  puts this_recycle_bin_item["_ref"]
  
  begin
    really_delete = [(print "Really delete? [N/y]:"), gets.rstrip][1]
    if really_delete.downcase == affirmative_answer then
      delete_result = @rally.delete(this_recycle_bin_item["_ref"])
      puts "DELETED #{item_formatted_id}: #{item_name}"
    else
      puts "Did NOT delete #{item_formatted_id}: #{item_name}."
    end
  rescue => ex
    puts "Error occurred trying to delete: #{item_formatted_id}: #{item_name}"
    puts ex
    puts ex.msg
    puts ex.backtrace
  end
end

begin

  #==================== Make a connection to Rally ====================

  config                  = {:base_url => $my_base_url}
  config[:username]       = $my_username
  config[:password]       = $my_password
  config[:workspace]      = $my_workspace
  config[:version]        = $wsapi_version
  config[:headers]        = $headers

  @rally = RallyAPI::RallyRestJson.new(config)

  # Read in Recycle Bin items that need deleting
  input  = CSV.read($filename)

  header = input.first #ignores first line

  rows   = []
  (1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }
  
  number_processed = 0

  # Proceed through rows in input CSV and delete Recycle Bin items contained therein
  puts "Deleting selected entries from the Recycle Bin..."
  
  rows.each do |row|
    delete_recycle_bin_entry(header, row)
    number_processed += 1
  end
  
  puts
  puts "Processed a total of #{number_processed} items from the Recycle Bin."
  puts "Complete!"

end