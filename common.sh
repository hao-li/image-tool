#!/bin/sh

function GetImgSize()
{
  imgFilePath=$1
  echo `mogrify -identify "$imgFilePath" | awk -F\  '{printf $3}'`
}

function GetImgWidth()
{
  imgFilePath=$1
  size=$(GetImgSize "$imgFilePath")
  echo $(GetImgWidthBySize "${size}")
}

function GetImgHeight()
{
  imgFilePath=$1
  size=$(GetImgSize "$imgFilePath")
  echo $(GetImgHeightBySize "${size}")
}

function GetImgWidthBySize()
{
  size=$1
  echo $size | awk -Fx  '{printf $1}'
}

function GetImgHeightBySize()
{
  size=$1
  echo $size | awk -Fx  '{printf $2}'
}

function ResizeImageByWidth()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  width_list=(${@:4})
  for width in ${width_list[@]}
  do
    tmp_file="${base_name}_tmp.${ext_name}"
    convert -resize ${width} ${base_name}.${ext_name} ${tmp_file}
    height=$(GetImgHeight ${tmp_file})
    dest_file="${dest_dir}/${base_name}_${width}_${height}.${ext_name}"
    mv "${tmp_file}" "${dest_file}"
  done
}

function ResizeImageByLteWidth()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  lte_width_list=(${@:4})
  for lte_width in ${lte_width_list[@]}
  do
    tmp_file="${base_name}_tmp.${ext_name}"
    convert -resize "${lte_width}>" ${base_name}.${ext_name} ${tmp_file}
    size=$(GetImgSize "${tmp_file}")
    width=$(GetImgWidthBySize "${size}")
    height=$(GetImgHeightBySize "${size}")
    dest_file="${dest_dir}/${base_name}_${width}_${height}.${ext_name}"
    mv "${tmp_file}" "${dest_file}"
  done
}

function ResizeImageByHeight()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  height_list=(${@:4})
  for height in ${height_list[@]}
  do
    tmp_file="${base_name}_tmp.${ext_name}"
    convert -resize x${height} ${base_name}.${ext_name} ${tmp_file}
    width=$(GetImgWidth ${tmp_file})
    dest_file="${dest_dir}/${base_name}_${width}_${height}.${ext_name}"
    mv "${tmp_file}" "${dest_file}"
  done
}

function CropImageByLength()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  length_list=(${@:4})
  for length in ${length_list[@]}
  do
    dest_file="${dest_dir}/${base_name}_s_${length}_${length}.${ext_name}"
    org_file="${base_name}.${ext_name}"
    org_size=$(GetImgSize "${org_file}")
    org_width=$(GetImgWidthBySize "${org_size}")
    org_height=$(GetImgHeightBySize "${org_size}")
    if [ "$org_width" -lt "$org_height" ]; then
      min_size=$org_width
    else
      min_size=$org_height
    fi
    convert -gravity center -crop ${min_size}x${min_size}+0+0 ${org_file} ${dest_file}
    mogrify -resize ${length}x${length} "${dest_file}"
  done
}

function CropImageBySize()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  size_list=(${@:4})
  for size in ${size_list[@]}
  do
    org_file="${base_name}.${ext_name}"
    org_size=$(GetImgSize "${org_file}")
    org_width=$(GetImgWidthBySize "${org_size}")
    org_height=$(GetImgHeightBySize "${org_size}")
    width=$(GetImgWidthBySize "${size}")
    height=$(GetImgHeightBySize "${size}")
    dest_file="${dest_dir}/${base_name}_s_${width}_${height}.${ext_name}"

    if [ "$(($org_width * $height))" -lt "$(($org_height * $width))" ]; then
      tmp_width=$org_width
      tmp_height=$(($height * $org_width / $width))
    else
      tmp_width=$(($width * $org_height / $height))
      tmp_height=$org_height
    fi
    echo ${tmp_width}x${tmp_height} $size ${org_width}x${org_height}
    convert -gravity center -crop ${tmp_width}x${tmp_height}+0+0 ${org_file} ${dest_file}
    mogrify -resize ${width}x${height} "${dest_file}"
  done
}

function GenerateImageByText()
{
  dest_dir=$1
  base_name=$2
  ext_name=$3
  text=$4
  font=$5
  background_color=$6
  fill_color=$7
  size_list=(${@:8})
  for size in ${size_list[@]}
  do
    width=$(GetImgWidthBySize "${size}")
    height=$(GetImgHeightBySize "${size}")
    dest_file="${dest_dir}/${base_name}_${width}_${height}.${ext_name}"
    convert -size "${size}" -gravity center -font "${font}" -background "${background_color}" -fill "${fill_color}" label:"${text}" "${dest_file}"
  done
}
