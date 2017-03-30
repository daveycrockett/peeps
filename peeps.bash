export PEEPSDB=$HOME/Documents/Dev/Projects/peeps/peeps.db
alias peepsdb='sqlite3 $PEEPSDB'

function empty_to_null {
  if [[ "$1" == '' ]];
  then
    echo "NULL"
  else
    echo "'$1'"
  fi
}

function silent_newline {
  if [[ ($1 == ' -s ') ]];
  then
    echo
  fi
}

function add_org {
  local acronym="$1"
  local org="$2"
  echo "
    INSERT OR REPLACE INTO orgs (acronym, name, notes) VALUES (
      UPPER($acronym),
      COALESCE(LOWER($org), (SELECT name FROM orgs WHERE acronym=UPPER($acronym))),
      (SELECT notes FROM orgs WHERE acronym=UPPER($acronym))
    );
  " | sqlite3 $PEEPSDB
}

function orgs {
  if [ $# -eq 0 ];
  then
    echo "usage: orgs <command> <args>. For specific help on a command, type `orgs help command`"
    return
  fi
  if [ $1 == 'help' ];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: orgs help <command>
possible commands are who, add, adds, note, notes"
      return -1
    fi
    case $2 in
      who)
        echo "orgs who <acronym>: lookup org by acronym"
        ;;
      add)
        echo "adds an org, with prompts, input shown"
        ;;
      adds)
        echo "adds an org, with prompts, sneaky input"
        ;;
      note)
        echo "orgs note <acronym>: append notes about an org with prompt"
        ;;
      notes)
        echo "orgs notes <acronym>: append notes about an org with prompt, sneaky input"
        ;;
     esac
  fi
  if [ $1 == 'who' ];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: orgs who <search-string>"
      return -1
    fi
    echo "SELECT * FROM orgs WHERE UPPER(acronym) LIKE UPPER('%$2%') OR LOWER(name) LIKE LOWER('%$2%');" | sqlite3 -column -header $PEEPSDB
  fi

  if [[ ($1 == 'adds' || $1 == 'notes' ) ]];
  then
    local silent=" -s "
  fi
  if [[ ($1 == 'adds' || $1 == 'add') ]];
  then
    local acronym org
    echo -n "name: "
    read $silent org
    org=$(empty_to_null "$org")
    silent_newline $silent

    echo -n "acronym: "
    read $silent acronym
    acronym=$(empty_to_null "$acronym")
    silent_newline $silent

    add_org "$acronym" "$org"
  fi
  if [[ ($1 == 'notes' || $1 == 'note' ) ]];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: peeps note[s] <acronym>"
      return -1
    fi
    local notes
    echo -n "notes: "
    read $silent notes
    silent_newline $silent

    echo "UPDATE orgs SET notes = (SELECT COALESCE(notes, '') FROM orgs WHERE UPPER(acronym) = UPPER('$2')) || '
' || DATE() || '
$notes';" | sqlite3 $PEEPSDB
  fi
}

function peeps {
  if [ $# -eq 0 ];
  then
    echo "usage: peeps <command> <args>. For specific help on a command, type `peeps help <command>`"
    return -1
  fi
  if [ $1 == 'help' ];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: peeps help <command>
possible commands are whoin, add, adds, who, note, notes"
      return -1
    fi
    case $2 in
      whoin)
        echo "peeps whoin <acronym>: substring search for people associated with an org whose acronym has the substring"
        ;;
      add)
        echo "peeps add: add a person, with prompts, input shown (will also add an org)"
        ;;
      adds)
        echo "peeps adds: add a person, with prompts, sneaky input (will also add an org)"
        ;;
      who)
        echo "peeqs who <name>: substring search for people by name"
        ;;
      note)
        echo "peeps note <name>: append notes about a person with prompt"
        ;;
      notes)
        echo "peeps notes <name>: append notes about a person with prompt, sneaky input"
        ;;
    esac
  fi
  if [ $1 == 'whoin' ];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: peeps whoin <acronym>"
      return -1
    fi
    echo "SELECT * FROM peeps WHERE UPPER(acronym) LIKE UPPER('%$2%') OR LOWER(orgname) LIKE LOWER('%$2%');" | sqlite3 -column -header $PEEPSDB
  fi
  if [ $1 == 'who' ];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: peeps who <search-string>"
      return -1
    fi
    echo "SELECT * FROM peeps WHERE LOWER(name) LIKE LOWER('%$2%');" | sqlite3 -column -header $PEEPSDB
  fi
  if [[ ($1 == 'adds' || $1 == 'notes') ]];
  then
    local silent=" -s "
  fi
  if [[ ($1 == 'adds' || $1 == 'add') ]];
  then
    local name email acronym org notes
    echo -n "name: "
    read $silent name
    name=$(empty_to_null "$name")
    silent_newline $silent

    echo -n "email: "
    read $silent email
    email=$(empty_to_null "$email")
    silent_newline $silent

    echo -n "org acronym: "
    read $silent acronym
    acronym=$(empty_to_null "$acronym")
    silent_newline $silent

    echo -n "org name: "
    read $silent org
    org=$(empty_to_null "$org")
    silent_newline $silent

    echo -n "notes: "
    read $silent notes
    silent_newline $silent
    local notesval=''
    if [ ! -z "$notes" ]; then
      notesval=" || '

' || DATE() || '
' || '$notes'"
    fi
    echo "
      INSERT OR REPLACE INTO peeps (name, email, acronym, orgname, notes)
      VALUES (
        LOWER($name),
        COALESCE(LOWER($email), (SELECT email FROM peeps WHERE name=LOWER($name))),
        COALESCE(UPPER($acronym), (SELECT acronym FROM peeps WHERE name=LOWER($name))),
        COALESCE(LOWER($org), (SELECT orgname FROM peeps WHERE name=LOWER($name)), (SELECT name FROM orgs WHERE acronym=UPPER($acronym))),
        COALESCE((SELECT notes FROM peeps WHERE name=LOWER($name)),'') $notesval
      );
    " | sqlite3 $PEEPSDB
    if [[ ( $acronym != "NULL" ) ]];
    then
      add_org "$acronym" "$org"
    fi
  fi
  if [[ ($1 == 'notes' || $1 == 'note' ) ]];
  then
    if [ $# -lt 2 ];
    then
      echo "usage: peeps note[s] <name>"
      return -1
    fi
    local notes
    echo -n "notes: "
    read $silent notes
    silent_newline $silent

    echo "UPDATE peeps SET notes = (SELECT COALESCE(notes, '') FROM peeps WHERE LOWER(name) = LOWER('$2')) || '
' || DATE() || '
$notes';" | sqlite3 $PEEPSDB
  fi
}
