#!/bin/sh

FORGE="`dirname \"$0\"`" # Relative
export FORGE="`( cd \"$FORGE\" && pwd )`" # Absolutized and normalized
pushd $FORGE > /dev/null


echo "Listing definitions..."
declare -a _yamls=();
for entry in ./v*/*.yaml; do
	_yamls=("${_yamls[@]}" $entry)
done

declare -a yamls=();
for entry in ${_yamls[@]}; do
	#declare -a patter=( ${Unix[@]/Red*/} )
	#echo $entry
	version="`([[ $entry =~ .*\/v([0-9]+)\/(.*) ]] && echo ${BASH_REMATCH[1]})`"
	filename="`([[ $entry =~ .*\/v([0-9]+)\/(.*) ]] && echo ${BASH_REMATCH[2]})`"
	yamls=("${yamls[@]}" $entry)
	COUNT=`expr $version - 1`
	for i in $(seq -1 $COUNT); do
		st="./v$i/$filename"
		declare -a res=( ${yamls[@]/$st/} )
		yamls=("${res[@]}")
	done
done

echo "Flattering definitions (yaml & json)..."
for entry in ${_yamls[@]}; do
	filename="`([[ $entry =~ .*\/v([0-9]+)\/(.*)\.yaml ]] && echo ${BASH_REMATCH[2]})`"
	node yaml-tools.js flattern --shared $entry > output/${filename}.yaml
	node yaml-tools.js flattern --shared $entry --json > output/${filename}.json
done

echo "Generating SDKs..." # php, ruby, csharp, forgejs
declare -a langs=("php" "ruby" "csharp")
for entry in ${_yamls[@]}; do
	filename="`([[ $entry =~ .*\/v([0-9]+)\/(.*)\.yaml ]] && echo ${BASH_REMATCH[2]})`"
	for lang in ${langs[@]}; do
		echo "    ($lang) $filename ..."
		node yaml-tools.js sdk $lang output/${filename}.yaml "clients/${lang}-${filename}.zip"
	done
done

# node yaml-tools.js sdk php output/forge-datamanagement.yaml clients/php-forge-datamanagement.zip
# node yaml-tools.js sdk ruby output/forge-datamanagement.yaml clients/ruby-forge-datamanagement.zip
# node yaml-tools.js sdk csharp output/forge-datamanagement.yaml clients/csharp-forge-datamanagement.zip
# node yaml-tools.js sdk php output/forge-oauth2.yaml clients/php-forge-oauth2.zip
# node yaml-tools.js sdk ruby output/forge-oauth2.yaml clients/ruby-forge-oauth2.zip
# node yaml-tools.js sdk csharp output/forge-oauth2.yaml clients/csharp-forge-oauth2.zip
# node yaml-tools.js sdk php output/forge-modelderivative.yaml clients/php-forge-modelderivative.zip
# node yaml-tools.js sdk ruby output/forge-modelderivative.yaml clients/ruby-forge-modelderivative.zip
# node yaml-tools.js sdk csharp output/forge-modelderivative.yaml clients/csharp-forge-modelderivative.zip
# node yaml-tools.js sdk php output/forge-oss.yaml clients/php-forge-oss.zip
# node yaml-tools.js sdk ruby output/forge-oss.yaml clients/ruby-forge-oss.zip
# node yaml-tools.js sdk csharp output/forge-oss.yaml clients/csharp-forge-oss.zip