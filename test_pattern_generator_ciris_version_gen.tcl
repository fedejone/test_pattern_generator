post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
post_message "This TCL test_pattern_generator_ciris_version_gen.tcl script starts before Quartus II build process!!!"
post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# get current hash and date from git repo
set hash_curr_commit [exec git describe --long  ]
set date_curr_commit [exec git show -s --pretty=format:"%ci"]

#open file for writing
set version_file [open rtl/test_pattern_generator_ciris_version_gen.svh w+]

# get versioning params using regilar expression
if [regexp {^v(\d*).(\d*)-(\d*)-g(.*)} $hash_curr_commit {} major minor revision sha] {

} else {
    puts $version_file "No match hash"
}

if [regexp {^\"(\d*)-(\d*)-(\d*).*\"} $date_curr_commit {} year month day] {

} else {
    puts $version_file "No match date"
}
post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
post_message "GIT VERSION test_pattern_generator_ciris"
post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
post_message [format "+ major: %s" $major]
post_message [format "+ minor: %s" $minor]
post_message [format "+ revision: %s" $revision]
post_message [format "+ sha: %s" $sha]
post_message [format "+ day month year: %s %s %s" $day $month $year]
post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
post_message "TCL close"
post_message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
puts $version_file " `define version_major_test_pattern_generator_ciris   4'd$major"
puts $version_file " `define version_minor_test_pattern_generator_ciris   6'd$minor"
puts $version_file " `define version_revision_test_pattern_generator_ciris   22'd$revision"

#close file
close $version_file