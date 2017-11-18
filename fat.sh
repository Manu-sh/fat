#!/bin/bash

trap sighandler EXIT

WORKDIR=$PWD
PROG_NAME=$(basename "${0%%.sh}")
TMP_DIR="/tmp/__${PROG_NAME}_$$"

sighandler() {
	rm -rfv $TMP_DIR
}

printUsage()  { echo "Usage: [-t xz|gz|bz2 ] [-f file ]"; }
default_err() { echo "$PROG_NAME Error: ${FUNCNAME[1]}() at line ${1}" >&2; exit 2; }
perror()      { echo "$PROG_NAME \"$1\": $2" >&2 ; } 

do_fat() {
	local format_tar_flag=$1 tar_name=$2 ext=$3
	echo -e '#!/bin/bash\n'      \
	"orig_name=\"${name}.fat\";" \
	'archive_name="${0##*./}";'  \
	'[ "${archive_name}" != "$orig_name" ] && { echo "the archive name should be: $orig_name, not $archive_name please rename it"; exit 2; };' \
	'[ -e "${archive_name%%.*}" ] && { echo "the file \"${archive_name%%.*}\" already exists"; exit 2; };' \
       	'tail +3 $0|tar kxv'"$format_tar_flag"' --; exit'|cat - "${TMP_DIR}/${tar_name}.${ext}" > "$WORKDIR/${name}.fat"
	chmod +x "$WORKDIR/${name}.fat"
}

archive() {
	local name=$1 ext=$2 
	mkdir -p $TMP_DIR
	tar -cavf "${TMP_DIR}/${name}.${ext}" "$name" 2>/dev/null || default_err $LINENO
}

while getopts t:f:h value "$@"; do

	case $value in

		t) 
			case $OPTARG in
				xz) format_tar_flag=J;  ext=txz  ;;
				gz) format_tar_flag=z;  ext=tgz  ;;
				bz2) format_tar_flag=j;	ext=tbz2 ;;
				*) perror "$OPTARG" "invalid archive type"; exit 2 ;;
			esac
		;;

		f)
			format_tar_flag=${format_tar_flag:-J}
			ext=${ext:-txz}
			fpathname="$OPTARG"
		;;

		?|h) printUsage; exit 0 ;;
	esac

done

! [ -n "$format_tar_flag" ] || [ -z "$fpathname" ] && { printUsage; exit 2; }
! [ -e "$fpathname"       ] && { perror "$fpathname" "file not found"; exit 2; }
! [ -r "$fpathname"       ] && { perror "$fpathname" "permission denied"; exit 2; }

cd "$(dirname $fpathname)"
name=$(basename $fpathname)

archive "$name" $ext
do_fat $format_tar_flag "$name" $ext
