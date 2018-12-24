#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -i IP(S) ] [ -g ANSIBLE-GROUP ] [ -a ANSIBLE-HOST-FILE ] [ -o FORCE-WRITE ]
    -i : Specify the IP address(es) of the host(s), if multiple, set in term of csv.
    -g : Specify the ansible group to make.
    -o : Overwrite the ansible group or not, no overwriting by default. 
    -a : Specify the ansible host file. If not specified, use '/etc/ansible/hosts' by default.
USAGE
exit 0
}
# Get Opts
while getopts "hi:g:oa:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    i)  HOSTS=$OPTARG # 参数存在$OPTARG中
        ;;
    g)  GROUP=$OPTARG
        ;;
    o)  OVERWRITE=true
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
chk_var -i $HOSTS
chk_var -g $GROUP
ANSIBLE=${ANSIBLE:-"/etc/ansible/hosts"}
DIR=${ANSIBLE%/*}
echo $DIR
mkdir -p $DIR
[ -f $ANSIBLE ] || touch $ANSIBLE
OVERWRITE=${OVERWRITE:-"false"}
HOSTS=$(echo $HOSTS | tr "," " ")
if cat $ANSIBLE | grep "\[$GROUP\]"; then
  if $OVERWRITE; then 
    #cat $ANSIBLE | grep -v "^#" | grep "^\[" |tr "\n" "?" | sed s/"\["/"\[%"/g | tr "[" "\n" | tr "%" "[" | sed /"\[$GROUP\]"/d | tr "?" "\n" | sed /"^$"/d > $ANSIBLE
    #cat $ANSIBLE | grep "^\[" |tr "\n" "?" | sed s/"\["/"\[%"/g | tr "[" "\n" | tr "%" "[" | sed /"\[$GROUP\]"/d | tr "?" "\n" | sed /"^$"/d > $ANSIBLE
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
    echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - ${GROUP} already in ${ANSIBLE}."
    echo " - still want to write, set '-o' flag"
    exit 1
  fi
fi
cat >> $ANSIBLE <<EOF
[$GROUP] 
EOF
for HOST in $HOSTS; do
  cat >> $ANSIBLE <<EOF
$HOST
EOF
done
