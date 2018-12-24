#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -g ANSIBLE-GROUP] [ -a ANSIBLE-HOST-FILE ]
    -g : Specify the ansible group to delete.
    -a : Specify the ansible host file. If not specified, use '/etc/ansible/hosts' by default.
USAGE
exit 0
}
# Get Opts
while getopts "hg:a:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    g)  GROUP=$OPTARG
        ;;
    a)  ANSIBLE=$OPTARG
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
[ -z "$*" ] && show_help
chk_var () {
if [ -z "$2" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no input for \"$1\", try \"$0 -h\"."
  sleep 3
  exit 1
fi
}
chk_var -g $GROUP
ANSIBLE=${ANSIBLE:-"/etc/ansible/hosts"}
if [ ! -f $ANSIBLE ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no ansible hosts file found, please check."
  sleep 3
  exit 1
fi
if cat $ANSIBLE | grep "\[$GROUP\]"; then
  FROMS=$(sed -n -e /"^\[${GROUP}"/= $ANSIBLE)
  for TMP in $FROMS; do
    FROM=$(sed -n -e /"^\[${GROUP}"/= $ANSIBLE)
    FROM=$(echo $FROM | awk -F ' ' '{print $1}')
    TARGETS=$(sed -n -e /"^\["/= $ANSIBLE)
    FOUND_BIGGER=false
    BIGGER=0
    MIN=9999999
    for i in $TARGETS; do
      if [[ "$i" > "$FROM" ]]; then
        BIGGER=$i
        FOUND_BIGGER=true
        if [[ "$BIGGER" < "$MIN" ]]; then
          MIN=$BIGGER
        fi
      fi
    done
    if $FOUND_BIGGER; then
      TARGET=$MIN
      TO=$[$TARGET-1]
    else
      TO='$'
    fi
    sed  -i "${FROM},${TO}"d $ANSIBLE 
  done
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [WARN] - ${GROUP} not in ${ANSIBLE}."
  sleep 3
fi
