#!/bin/sh
#

function list_ssh_keys {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-key-pairs | jq -r '.KeyPairs[] | .KeyPairId + ":" + .KeyName'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f2)
}

function list_subnets {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-subnets | jq -r ".Subnets[] | select( .VpcId == \"$vpc_id\" ) | .SubnetId + \":\" + .CidrBlock + \":\" + (.Tags // [] | map(select(.Key == \"Name\") | .Value) | join(\":\"))"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_vpc {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-vpcs | jq -r '.Vpcs[] | .VpcId + ":" + .CidrBlock + ":" + (.Tags // [] | map(select(.Key == "Name") | .Value) | join(";"))'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_sg {
local result_array=()
local -n return_value=$1

for item in $(aws ec2 describe-security-groups | jq -r ".SecurityGroups[] | select( .VpcId == \"$vpc_id\" ) | .GroupId + \":\" + .GroupName" | sed -e 's/ /_/g'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=$(echo ${result_array[$INPUT]} | cut -d: -f1)
}

function list_priv_keys {
local result_array=()
local -n return_value=$1

for item in $(ls -l -I "*.pub" /home/admin/.ssh/id* /home/admin/.ssh/*.pem | awk '{print $NF}'); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function get_domain_name {
local -n return_value=$1
local host_domain=$(grep search /etc/resolv.conf | awk '{print $2}')

echo -n "domain_name [$host_domain]: "
read INPUT
if [ -n "$INPUT" ]; then
   return_value=$INPUT
else
   return_value=$host_domain
fi
}

function get_dns_server {
local -n return_value=$1
local host_nameserver=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)

echo -n "dns_server [$host_nameserver]: "
read INPUT
if [ -n "$INPUT" ]; then
   return_value=$INPUT
else
   return_value=$host_nameserver
fi
}

host_name_prefix="perfdb"
gen_name_prefix="perfgen"
domain_name=""
dns_server=""
sw_version="7.0.1-6102"
region_name="us-east-2"
instance_type="c4.xlarge"
gen_instance_type="c4.xlarge"
num_instances="3"
gen_instances="1"
start_num="1"
gen_start_num="1"
ssh_user="centos"
ssh_key=""
ssh_private_key=""
subnet_id=""
vpc_id=""
security_group_ids=""
root_volume_iops="0"
root_volume_size="50"
root_volume_type="gp2"

aws s3 ls >/dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "Please refresh AWS credentials."
   exit 1
fi

if [ ! -f variables.template ]; then
   echo "Please run the script from the directory with file variables.template."
   exit 1
fi

while getopts "c" opt
do
  case $opt in
    c)
      if [ ! -f variables.clean -o ! -f cluster.clean ]; then
         echo "Sanitized variable files not found."
         exit 1
      fi
      cp variables.clean variables.tf
      cp cluster.clean cluster.tf
      exit
      ;;
    \?)
      exit 1
      ;;
  esac
done

echo -n "Configure variables? (y/n) [y]:"
read INPUT
if [ "$INPUT" == "y" -o -z "$INPUT" ]; then

echo -n "host_name_prefix [$host_name_prefix]: "
read INPUT
if [ -n "$INPUT" ]; then
   host_name_prefix=$INPUT
fi

echo -n "gen_name_prefix [$gen_name_prefix]: "
read INPUT
if [ -n "$INPUT" ]; then
   gen_name_prefix=$INPUT
fi

get_domain_name domain_name

get_dns_server dns_server

echo -n "sw_version [$sw_version]: "
read INPUT
if [ -n "$INPUT" ]; then
   sw_version=$INPUT
fi
echo -n "region_name [$region_name]: "
read INPUT
if [ -n "$INPUT" ]; then
   region_name=$INPUT
fi
echo -n "instance_type [$instance_type]: "
read INPUT
if [ -n "$INPUT" ]; then
   instance_type=$INPUT
fi
echo -n "gen_instance_type [$gen_instance_type]: "
read INPUT
if [ -n "$INPUT" ]; then
   gen_instance_type=$INPUT
fi
echo -n "num_instances [$num_instances]: "
read INPUT
if [ -n "$INPUT" ]; then
   num_instances=$INPUT
fi
echo -n "gen_instances [$gen_instances]: "
read INPUT
if [ -n "$INPUT" ]; then
   gen_instances=$INPUT
fi
echo -n "start_num [$start_num]: "
read INPUT
if [ -n "$INPUT" ]; then
   start_num=$INPUT
fi
echo -n "gen_start_num [$gen_start_num]: "
read INPUT
if [ -n "$INPUT" ]; then
   gen_start_num=$INPUT
fi
echo -n "ssh_user [$ssh_user]: "
read INPUT
if [ -n "$INPUT" ]; then
   ssh_user=$INPUT
fi

echo "SSH Key:"
list_ssh_keys ssh_key

echo "SSH Private Key file:"
list_priv_keys ssh_private_key

echo "VPC ID:"
list_vpc vpc_id

echo "Subnet ID:"
list_subnets subnet_id

echo "Security Group ID:"
list_sg security_group_ids

echo -n "root_volume_iops [$root_volume_iops]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_iops=$INPUT
fi

echo -n "root_volume_size [$root_volume_size]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_size=$INPUT
fi

echo -n "root_volume_type [$root_volume_type]: "
read INPUT
if [ -n "$INPUT" ]; then
   root_volume_size=$INPUT
fi

echo ""
echo "host_name_prefix   : $host_name_prefix"
echo "gen_name_prefix    : $gen_name_prefix"
echo "domain_name        : $domain_name"
echo "dns_server         : $dns_server"
echo "sw_version         : $sw_version"
echo "region_name        : $region_name"
echo "instance_type      : $instance_type"
echo "gen_instance_type  : $gen_instance_type"
echo "num_instances      : $num_instances"
echo "gen_instances      : $gen_instances"
echo "start_num          : $start_num"
echo "gen_start_num      : $gen_start_num"
echo "ssh_user           : $ssh_user"
echo "ssh_key            : $ssh_key"
echo "ssh_private_key    : $ssh_private_key"
echo "subnet_id          : $subnet_id"
echo "vpc_id             : $vpc_id"
echo "security_group_ids : $security_group_ids"
echo "root_volume_iops   : $root_volume_iops"
echo "root_volume_size   : $root_volume_size"
echo "root_volume_type   : $root_volume_type"
echo ""
echo -n "Write these to the variables file? [y/n]: "
read INPUT
if [ "$INPUT" != "y" ]; then
   echo "No changes made."
   exit
fi

ssh_private_key=$(echo "$ssh_private_key" | sed -e 's/\//\\\//g')

sed -e "s/\bHOST_NAME_PREFIX\b/$host_name_prefix/" \
    -e "s/\bGEN_NAME_PREFIX\b/$gen_name_prefix/" \
    -e "s/\bDOMAIN_NAME\b/$domain_name/" \
    -e "s/\bDNS_SERVER\b/$dns_server/" \
    -e "s/\bSW_VERSION\b/$sw_version/" \
    -e "s/\bREGION_NAME\b/$region_name/" \
    -e "s/\bINSTANCE_TYPE\b/$instance_type/" \
    -e "s/\bGEN_INSTANCE_TYPE\b/$gen_instance_type/" \
    -e "s/\bNUM_INSTANCES\b/$num_instances/" \
    -e "s/\bGEN_INSTANCES\b/$gen_instances/" \
    -e "s/\bSTART_NUM\b/$start_num/" \
    -e "s/\bGEN_START_NUM\b/$gen_start_num/" \
    -e "s/\bSSH_USER\b/$ssh_user/" \
    -e "s/\bSSH_KEY\b/$ssh_key/" \
    -e "s/\bSSH_PRIVATE_KEY\b/$ssh_private_key/" \
    -e "s/\bSUBNET_ID\b/$subnet_id/" \
    -e "s/\bVPC_ID\b/$vpc_id/" \
    -e "s/\bSECURITY_GROUP_IDS\b/$security_group_ids/" \
    -e "s/\bROOT_VOLUME_IOPS\b/$root_volume_iops/" \
    -e "s/\bROOT_VOLUME_SIZE\b/$root_volume_size/" \
    -e "s/\bROOT_VOLUME_TYPE\b/$root_volume_type/" variables.template > variables.tf

echo "File variables.tf written."
fi

echo ""
echo "Configuring nodes."
TMPFILE=$(mktemp)

cat <<EOF > $TMPFILE
##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "cluster_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
EOF

for i in $(seq $num_instances); do
  node_num_str=$(printf "%02d" $i)
  echo "=> Configuring instance $i ..."
  echo -n "instance_type [$instance_type]: "
  read INPUT
  if [ -n "$INPUT" ]; then
     instance_type=$INPUT
  fi
  service_string=""
  list_item=1
  for service in data index query fts analytics eventing
  do
    if [ "$service" == "data" ]; then
      default_answer="y"
    else
      default_answer="n"
    fi
    echo -n "  -> $service (y/n) [$default_answer]:"
    read INPUT
    [ -z "$INPUT" ] && INPUT=$default_answer
    if [ "$INPUT" == "y" ]; then
      if [ "$list_item" -eq 1 ]; then
        service_string="$service"
      else
        service_string="${service_string},${service}"
      fi
      list_item=$(($list_item + 1))
    fi
  done
cat <<EOF >> $TMPFILE
    cbnode-$node_num_str = {
      node_number     = $i,
      node_services   = "${service_string}",
      node_role       = "database"
      instance_type   = "${instance_type}",
    }
EOF
done

cat <<EOF >> $TMPFILE
  }
}

variable "generator_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
EOF

for i in $(seq $gen_instances); do
  node_num_str=$(printf "%02d" $i)
  echo "=> Configuring generator $i ..."
  echo -n "instance_type [$instance_type]: "
  read INPUT
  if [ -n "$INPUT" ]; then
     instance_type=$INPUT
  fi
cat <<EOF >> $TMPFILE
    loadgen-$node_num_str = {
      node_number     = $i,
      node_services   = "docker",
      node_role       = "generator"
      instance_type   = "${instance_type}",
    }
EOF
done

cat <<EOF >> $TMPFILE
  }
}
EOF

echo ""
cat $TMPFILE
echo -n "Write this to the cluster file? [y/n]: "
read INPUT
if [ "$INPUT" != "y" ]; then
   echo "No changes made."
   rm $TMPFILE
   exit
fi

cp $TMPFILE cluster.tf
echo "File cluster.tf written."

rm $TMPFILE
echo "Done."
##