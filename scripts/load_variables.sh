#!/bin/sh
#

function list_dc {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --getdc true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_datacenters) | .vmware_datacenters[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_cluster {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --vmware_dc $vsphere_datacenter --getcl true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_clusters) | .vmware_clusters[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_datastore {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --vmware_dc $vsphere_datacenter --getds true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_datastores) | .vmware_datastores[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_dvs {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --vmware_dc $vsphere_datacenter --getdvs true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_dvs) | .vmware_dvs[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_pg {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --vmware_dc $vsphere_datacenter --vmware_dvs $vsphere_dvs_switch --getpg true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_pg) | .vmware_pg[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_template {
local result_array=()
local -n return_value=$1

for item in $(ansible-helper.py vmware-get-info.yaml -j --vmware_host $vsphere_server --vmware_user $vsphere_user --vsphere_password $vsphere_password --vmware_dc $vsphere_datacenter --gettmpl true 2>/dev/null | jq -r ".plays[] | .tasks[] | .hosts.localhost | select(.vmware_template) | .vmware_template[]"); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}
}

function list_priv_keys {
local result_array=()
local -n return_value=$1

for item in $(ls -I "*.pub" -I config -I known_hosts -I authorized_keys /home/admin/.ssh/ | awk '{print "/home/admin/.ssh/"$NF}'); do
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

function get_index_mem {
local -n return_value=$1

echo "1) default"
echo "2) memopt"
echo -n "index_memory [1]: "
read INPUT
[ -z "$INPUT" ] && INPUT=1
if [ "$INPUT" -eq 1 ]; then
  index_memory="false"
else
  index_memory="true"
fi
}

function get_cb_version {
local -n return_value=$1
local PACKAGES=$(curl -s http://packages.couchbase.com/releases/couchbase-server/enterprise/rpm/7/x86_64/repodata/repomd.xml | grep filelists.xml | cut -d\" -f2)

for item in $(curl -s http://packages.couchbase.com/releases/couchbase-server/enterprise/rpm/7/x86_64/$PACKAGES | zcat | grep ver= | awk -F\" '{print $4"-"$6}' | tac | head -10); do
    result_array+=("$item")
done

for (( i=0; i<${#result_array[@]}; i++ )); do
    echo "$i) ${result_array[$i]}"
done

echo -n "Selection: "
read INPUT

return_value=${result_array[$INPUT]}

}

domain_name=""
dns_server=""
vsphere_user="administrator@vsphere.local"
vsphere_password=""
vsphere_server=""
vsphere_datacenter=""
vsphere_cluster=""
vsphere_datastore=""
vsphere_dvs_switch=""
vsphere_network=""
vsphere_template=""
vm_num_vcpu="4"
vm_ram="8192"
sw_version="7.0.1-6102"
region_name="us-east-2"
instance_type="c4.xlarge"
gen_instance_type="c4.xlarge"
index_memory="false"
num_instances="3"
gen_instances="1"
start_num="1"
gen_start_num="1"
ssh_user="admin"
ssh_key=""
ssh_private_key=""
subnet_id=""
vpc_id=""
security_group_ids=""
root_volume_iops="0"
root_volume_size="50"
root_volume_type="gp2"

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

echo "Domain Name:"
get_domain_name domain_name

echo "DNS Server:"
get_dns_server dns_server

[ -n "$domain_name" ] && vsphere_user="administrator@$domain_name"
echo -n "vsphere_user [$vsphere_user]: "
read INPUT
if [ -n "$INPUT" ]; then
   vsphere_user=$INPUT
fi

echo -n "vsphere_password: "
read -s INPUT
echo ""
if [ -n "$INPUT" ]; then
   vsphere_password=$INPUT
fi

echo -n "vsphere_server: "
read INPUT
if [ -n "$INPUT" ]; then
   vsphere_server=$INPUT
fi

echo "vSphere Datacenter:"
list_dc vsphere_datacenter

echo "vSphere Cluster:"
list_cluster vsphere_cluster

echo "vSphere Datastore:"
list_datastore vsphere_datastore

echo "vSphere DVSwitch:"
list_dvs vsphere_dvs_switch

echo "vSphere Port Group (network):"
list_pg vsphere_network

echo "VM Template:"
list_template vsphere_template

echo "Software version:"
get_cb_version sw_version

echo "Index storage option:"
get_index_mem index_memory

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

echo -n "ssh_user [$ssh_user]: "
read INPUT
if [ -n "$INPUT" ]; then
   ssh_user=$INPUT
fi

echo "SSH Private Key file:"
list_priv_keys ssh_private_key

echo -n "vm_num_vcpu [$vm_num_vcpu]: "
read INPUT
if [ -n "$INPUT" ]; then
   vm_num_vcpu=$INPUT
fi

echo -n "vm_ram [$vm_ram]: "
read INPUT
if [ -n "$INPUT" ]; then
   vm_ram=$INPUT
fi

echo ""

echo "domain_name        : $domain_name"
echo "dns_server         : $dns_server"
echo "vsphere_user       : $vsphere_user"
echo "vsphere_password   : ********"
echo "vsphere_server     : $vsphere_server"
echo "vsphere_datacenter : $vsphere_datacenter"
echo "vsphere_cluster    : $vsphere_cluster"
echo "vsphere_datastore  : $vsphere_datastore"
echo "vsphere_dvs_switch : $vsphere_dvs_switch"
echo "vsphere_network    : $vsphere_network"
echo "vsphere_template   : $vsphere_template"
echo "sw_version         : $sw_version"
echo "index_memory       : $index_memory"
echo "num_instances      : $num_instances"
echo "gen_instances      : $gen_instances"
echo "ssh_user           : $ssh_user"
echo "ssh_private_key    : $ssh_private_key"
echo "vm_num_vcpu        : $vm_num_vcpu"
echo "vm_ram             : $vm_ram"
echo ""
echo -n "Write these to the variables file? [y/n]: "
read INPUT
if [ "$INPUT" != "y" ]; then
   echo "No changes made."
   exit
fi

ssh_private_key=$(echo "$ssh_private_key" | sed -e 's/\//\\\//g')

sed -e "s/\bDOMAIN_NAME\b/$domain_name/" \
    -e "s/\bDNS_SERVER\b/$dns_server/" \
    -e "s/\bVSPHERE_USER\b/$vsphere_user/" \
    -e "s/\bVSPHERE_PASSWORD\b/$vsphere_password/" \
    -e "s/\bVSPHERE_SERVER\b/$vsphere_server/" \
    -e "s/\bVSPHERE_DATACENTER\b/$vsphere_datacenter/" \
    -e "s/\bVSPHERE_CLUSTER\b/$vsphere_cluster/" \
    -e "s/\bVSPHERE_DATASTORE\b/$vsphere_datastore/" \
    -e "s/\bVSPHERE_DVS_SWITCH\b/$vsphere_dvs_switch/" \
    -e "s/\bVSPHERE_NETWORK\b/$vsphere_network/" \
    -e "s/\bVSPHERE_TEMPLATE\b/$vsphere_template/" \
    -e "s/\bSW_VERSION\b/$sw_version/" \
    -e "s/\bINDEX_MEMORY\b/$index_memory/" \
    -e "s/\bNUM_INSTANCES\b/$num_instances/" \
    -e "s/\bGEN_INSTANCES\b/$gen_instances/" \
    -e "s/\bSSH_USER\b/$ssh_user/" \
    -e "s/\bSSH_PRIVATE_KEY\b/$ssh_private_key/" \
    -e "s/\bVM_NUM_VCPU\b/$vm_num_vcpu/" \
    -e "s/\bVM_RAM\b/$vm_ram/" variables.template > variables.tf

echo "File variables.tf written."
fi

echo -n "Configure nodes? (y/n) [y]:"
read INPUT
if [ "$INPUT" == "y" -o -z "$INPUT" ]; then
echo ""
echo "Configuring nodes."
TMPFILE=$(mktemp)

cat <<EOF > $TMPFILE
##########################################################
#
# Default values for creating a Couchbase cluster on VMware.
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
  echo -n "template [$vsphere_template]: "
  read INPUT
  if [ -n "$INPUT" ]; then
     vsphere_template=$INPUT
  fi
  service_string=""
  list_item=1
  for service in data index query fts analytics eventing
  do
    if [ "$service" == "data" -o "$service" == "index" -o "$service" == "query" ]; then
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
      node_number      = $i,
      node_services    = "${service_string}",
      node_role        = "database"
      vsphere_template = "${vsphere_template}",
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
  echo -n "template [$vsphere_template]: "
  read INPUT
  if [ -n "$INPUT" ]; then
     vsphere_template=$INPUT
  fi
cat <<EOF >> $TMPFILE
    loadgen-$node_num_str = {
      node_number      = $i,
      node_services    = "docker",
      node_role        = "generator"
      vsphere_template = "${vsphere_template}",
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
fi

rm $TMPFILE
echo "Done."
##