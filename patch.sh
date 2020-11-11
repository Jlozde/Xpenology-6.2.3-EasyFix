#!/bin/sh
set -eo pipefail;
shopt -s nullglob;

#variables
bin_file="synocodectool"
conf_file="activation.conf"
conf_path="/usr/syno/etc/codec"
conf_string='{"success":true,"activated_codec":["hevc_dec","ac3_dec","h264_dec","h264_enc","aac_dec","aac_enc","mpeg4part2_dec","vc1_dec","vc1_enc"],"token":"123456789987654abc"}'
conf_path1=""
conf_library_patched=1

#arrays
declare -A binhash_version_list=(
    ["cde88ed8fdb2bfeda8de52ef3adede87a72326ef"]="6.0-7321-0_6.0.3-8754-8"
    ["ec0c3f5bbb857fa84f5d1153545d30d7b408520b"]="6.1-15047-0_6.1.1-15101-4"
    ["1473d6ad6ff6e5b8419c6b0bc41006b72fd777dd"]="6.1.2-15132-0_6.1.3-15152-8"
    ["26e42e43b393811c176dac651efc5d61e4569305"]="6.1.4-15217-0_6.2-23739-2"
    ["1d01ee38211f21c67a4311f90315568b3fa530e6"]="6.2.1-23824-0_6.2.3-25426-2"
)

declare -A patchhash_binhash_list=(
    ["e5c1a65b3967968560476fcda5071fd37db40223"]="cde88ed8fdb2bfeda8de52ef3adede87a72326ef"
    ["d58f5b33ff2b6f2141036837ddf15dd5188384c6"]="ec0c3f5bbb857fa84f5d1153545d30d7b408520b"
    ["56ca9adaf117e8aae9a3a2e29bbcebf0d8903a99"]="1473d6ad6ff6e5b8419c6b0bc41006b72fd777dd"
    ["511dec657daa60b0f11da20295e2c665ba2c749c"]="26e42e43b393811c176dac651efc5d61e4569305"
    ["93067026c251b100e27805a8b4b9d8f0ae8e291c"]="1d01ee38211f21c67a4311f90315568b3fa530e6"
)

declare -A binhash_patch_list=(
    ["cde88ed8fdb2bfeda8de52ef3adede87a72326ef"]="00002dc0: 27000084c0eb4cb9b6000000badd6940\n00003660: 24f0000000e8961e000084c00f84b400"
    ["ec0c3f5bbb857fa84f5d1153545d30d7b408520b"]="00002dc0: 27000084c0eb4cb9b7000000bafd6940\n000036f0: 0000e8291e000084c0eb1eb9ec000000"
    ["1473d6ad6ff6e5b8419c6b0bc41006b72fd777dd"]="00002dc0: 27000084c0eb4cb9b7000000baad6a40\n000036f0: 0000e8291e000084c0eb1eb9ec000000"
    ["26e42e43b393811c176dac651efc5d61e4569305"]="00002dc0: 27000084c0eb4cb9ba000000badf6a40\n00003710: f0000000e8271e000084c0eb1eb9ef00"
    ["1d01ee38211f21c67a4311f90315568b3fa530e6"]="00002dc0: 27000084c0eb4cb9bd000000baf76a40\n00003720: 24f0000000e8261e000084c0eb1eb9f2"
)

declare -a binpath_list=()

declare -a path_list=(
    "/usr/syno/bin"
    "/volume1/@appstore/VideoStation/bin"
    "/volume2/@appstore/VideoStation/bin"
    "/volume3/@appstore/VideoStation/bin"
    "/volume1/@appstore/MediaServer/bin/"
    "/volume2/@appstore/MediaServer/bin/"
    "/volume3/@appstore/MediaServer/bin/"    
)

declare -a versions_list=(
    "6.0 7321-0"
    "6.0 7321-1"
    "6.0 7321-2"
    "6.0 7321-3"
    "6.0 7321-4"
    "6.0 7321-5"
    "6.0 7321-6"
    "6.0 7321-7"
    "6.0.1 7393-0"
    "6.0.1 7393-1"
    "6.0.1 7393-2"
    "6.0.2 8451-0"
    "6.0.2 8451-1"
    "6.0.2 8451-2"
    "6.0.2 8451-3"
    "6.0.2 8451-4"
    "6.0.2 8451-5"
    "6.0.2 8451-6"
    "6.0.2 8451-7"
    "6.0.2 8451-8"
    "6.0.2 8451-9"
    "6.0.2 8451-10"
    "6.0.2 8451-11"
    "6.0.3 8754-0"
    "6.0.3 8754-1"
    "6.0.3 8754-2"
    "6.0.3 8754-3"
    "6.0.3 8754-4"
    "6.0.3 8754-5"
    "6.0.3 8754-6"
    "6.0.3 8754-7"
    "6.0.3 8754-8"
    "6.1 15047-0"
    "6.1 15047-1"
    "6.1 15047-2"
    "6.1.1 15101-0"
    "6.1.1 15101-1"
    "6.1.1 15101-2"
    "6.1.1 15101-3"
    "6.1.1 15101-4"
    "6.1.2 15132-0"
    "6.1.2 15132-1"
    "6.1.3 15152-0"
    "6.1.3 15152-1"
    "6.1.3 15152-2"
    "6.1.3 15152-3"
    "6.1.3 15152-4"
    "6.1.3 15152-5"
    "6.1.3 15152-6"
    "6.1.3 15152-7"
    "6.1.3 15152-8"
    "6.1.4 15217-0"
    "6.1.4 15217-1"
    "6.1.4 15217-2"
    "6.1.4 15217-3"
    "6.1.4 15217-4"
    "6.1.4 15217-5"
    "6.1.4 15217-0"
    "6.1.5 15254-0"
    "6.1.5 15254-1"
    "6.1.6 15266-0"
    "6.1.6 15266-1"
    "6.1.7 15284-0"
    "6.1.7 15284-1"
    "6.1.7 15284-2"
    "6.1.7 15284-3"
    "6.2 23739-0"
    "6.2 23739-1"
    "6.2 23739-2"
    "6.2.1 23824-0"
    "6.2.1 23824-1"
    "6.2.1 23824-2"
    "6.2.1 23824-3"
    "6.2.1 23824-4"
    "6.2.1 23824-5"
    "6.2.1 23824-6"
    "6.2.2 24922-0"
    "6.2.2 24922-1"
    "6.2.2 24922-2"
    "6.2.2 24922-3"
    "6.2.2 24922-4"
    "6.2.2 24922-5"
    "6.2.2 24922-6"
    "6.2.3 25423-0"
    "6.2.3 25426-0"
    "6.2.3 25426-1"
    "6.2.3 25426-2"
)

#functions
check_path () {
    for i in "${path_list[@]}"; do
        if [ -e "$i/$bin_file" ]; then
            binpath_list+=( "$i/$bin_file" )
        fi
    done
}

check_version () {
    local ver="$1"
    for i in "${versions_list[@]}" ; do
        [[ "$i" == "$ver" ]] && return 0
    done ||  return 1
}

list_versions () {
    for i in "${versions_list[@]}"; do
        echo "$i"
    done
    return 0
}

patch () {
    source "/etc/VERSION"
    dsm_version="$productversion $buildnumber-$smallfixnumber"
    if [[ ! "$dsm_version" ]] ; then
        echo "Something went wrong. Could not fetch DSM version"
        exit 1
    fi

    echo "Detected DSM version: $dsm_version"

    if ! check_version "$dsm_version" ; then
        echo "Patch for DSM Version ($dsm_version) not found."
        echo "Patch is available for versions: "
        list_versions
        exit 1
    fi
    
    echo "Patch for DSM Version ($dsm_version) AVAILABLE!"    
    check_path
    
    if  ! (( ${#binpath_list[@]} )) ; then
        echo "Something went wrong. Could not find synocodectool"
        exit 1
    fi
    
    for option in "${binpath_list[@]}";
    do
	echo $option
	bin_path="$option"
	local backup_path="${bin_path%??????????????}/backup"
	conf_path1=$backup_path
        local synocodectool_hash="$(sha1sum "$bin_path" | cut -f1 -d\ )"
        if [[ "${binhash_version_list[$synocodectool_hash]+isset}" ]] ; then
            local backup_identifier="${synocodectool_hash:0:8}"
            if [[ -f "$backup_path/$bin_file.$backup_identifier" ]]; then
                backup_hash="$(sha1sum "$backup_path/$bin_file.$backup_identifier" | cut -f1 -d\ )"
                if [[ "${binhash_version_list[$backup_hash]+isset}" ]]; then
                    echo "Restored synocodectool and valid backup detected (DSM ${binhash_version_list[$backup_hash]}) . Patching..."
                    echo -e "${binhash_patch_list[$synocodectool_hash]}" | xxd -r - "$bin_path"                
                    echo "Patched successfully"
                    echo "Creating spoofed activation.conf.."
                    if [ ! -e "$conf_path/$conf_file" ] ; then
                        mkdir -p $conf_path
                        echo "$conf_string" > "$conf_path/$conf_file"
                        echo "Spoofed activation.conf created successfully"
			library_patch
                        exit 0
                    else
                        rm "$conf_path/$conf_file"
                        echo "$conf_string" > "$conf_path/$conf_file"
                        echo "Spoofed activation.conf created successfully"
			library_patch
                        exit 0
                    fi
                else
                    echo "Corrupted backup and original synocodectool detected. Overwriting backup..."
                    mkdir -p "$backup_path"
                    cp -p "$bin_path" \
                    "$backup_path/$bin_file.$backup_identifier"
                    exit 0
                fi
            else    
                echo "Detected valid synocodectool. Creating backup.."
                mkdir -p "$backup_path"
                cp -p "$bin_path" \
                "$backup_path/$bin_file.$backup_identifier"
                echo "Patching..."
                echo -e "${binhash_patch_list[$synocodectool_hash]}" | xxd -r - "$bin_path"            
                echo "Patched"
                echo "Creating spoofed activation.conf.."
                if [ ! -e "$conf_path/$conf_file" ] ; then
                    mkdir -p $conf_path
                    echo "$conf_string" > "$conf_path/$conf_file"
                    echo "Spoofed activation.conf created successfully"
		    library_patch
                    exit 0
                else
                    rm "$conf_path/$conf_file"
                    echo "$conf_string" > "$conf_path/$conf_file"
                    echo "Spoofed activation.conf created successfully"
		    library_patch
                    exit 0
                fi
            fi
        elif [[ "${patchhash_binhash_list[$synocodectool_hash]+isset}" ]]; then
            local original_hash="${patchhash_binhash_list[$synocodectool_hash]}"
            local backup_identifier="${original_hash:0:8}"
            if [[ -f "$backup_path/$bin_file.$backup_identifier" ]]; then
                backup_hash="$(sha1sum "$backup_path/$bin_file.$backup_identifier" | cut -f1 -d\ )"
                if [[ "$original_hash"="$backup_hash" ]]; then
                    echo "Valid backup and patched synocodectool detected. Skipping patch."
		    library_patch
                    exit 0
                else
                    echo "Patched synocodectool and corrupted backup detected. Skipping patch."
		    library_patch
                    exit 1
                fi
            else
                echo "Patched synocodectool and no backup detected. Skipping patch."
		library_patch
                exit 1  
            fi
        else
            echo "Corrupted synocodectool detected. Please use the -r option to try restoring it."
	    library_patch
            exit 1
        fi 
    done
}

library_patch (){
if [["$conf_library_patched"]]; then
    echo "Backing up libraries..." 
    cp -p "/var/packages/SynologyMoments/target/usr/lib/libsynophoto-plugin-detection.so" "/"$conf_path1"/libsynophoto-plugin-detection_backup.so"
    rm "/var/packages/SynologyMoments/target/usr/lib/libsynophoto-plugin-detection.so"
    wget -P "/var/packages/SynologyMoments/target/usr/lib/" "https://raw.githubusercontent.com/Jlozde/xpenology-6.2.3-easyfix/master/libsynophoto-plugin-detection.so"
    echo "backed up to:"$backup_path."/libsynophoto-plugin-detection_backup.so"
    conf_library_patched=0
fi
}

#main()
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

patch
exit 0
