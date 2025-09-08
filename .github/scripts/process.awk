#!/usr/bin/env awk -f

BEGIN {
  # identify source code language for each directory
  while ("cat cfg_for_dir.txt" | getline) {
    # fields are delimited with a semicolon
    split($0, record, ";")
    # cfg_for_dir[<path>][<cfg.key>] = <cfg.value>
    cfg_for_dir[record[1]]["lang"] = record[2]
    cfg_for_dir[record[1]]["build_mode"] = record[3]
  }

  # create dirs variable as empty array
  split("", dirs)
  split("", no_changes)
  

  # field separator is path separator for linux
  FS = "/"
}

{
  # skip directory if already procesed
  if (!dirs[$1]) {
    # record directory where files have changed, and programming language for codeql analysis 
    dirs[$1] = sprintf( \
      "{\"directory\": \"%s\", \"language\": \"%s\", \"build_mode\": \"%s\"}", \
      $1, \
      cfg_for_dir[$1]["lang"], \
      cfg_for_dir[$1]["build_mode"] \
    )
  }

  # record directory where no files have changed
  for (key in cfg_for_dir) {
    if (!(key in dirs)) {
      no_changes[key] = sprintf( \
        "{\"directory\": \"%s\", \"language\": \"%s\", \"build_mode\": \"%s\"}", \
        key, \
        cfg_for_dir[key]["lang"], \
        cfg_for_dir[key]["build_mode"] \
      )
    }
  }
  
}

END {
  printf "{ \"changes\":["

  # Print changes
  sep = ""
  for (key in dirs) {
    printf "%s%s", sep, dirs[key]
    sep = ","
  }

  printf "], \"no_changes\":["

  # Print no_changes
  sep = ""
  for (key in no_changes) {
    printf "%s%s", sep, no_changes[key]
    sep = ","
  }

  printf "]}\n"
}