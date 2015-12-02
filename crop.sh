#!/bin/sh

set -u

src_dir=$1
dest_dir=$2
lenght=$3

. "`dirname $0`/common.sh"

img_height=($length)

cd "${src_dir}"
for file in *.jpg
do
  echo $file
  base_file=`echo $(basename "${file}") | awk -F. '{print $1}'`
  org_file="${file}"
  org_size=$(GetImgSize "${org_file}")
  org_width=$(GetImgWidthBySize "${org_size}")
  org_height=$(GetImgHeightBySize "${org_size}")

  echo $dest_dir
  echo $base_file
  echo ${img_height[@]}
  CropImageByLength "${dest_dir}" "${base_file}" "jpg" ${img_height[@]}
done
cd -
