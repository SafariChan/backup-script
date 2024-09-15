#!/bin/bash

log_error() {
	echo "$1" >> error.log
}

#function to perform backup

perform_backup() {
	local directory=$1
	local compression=$2
	local output=$3
        
	case $compression in
		non)
			tar cf "output.tar" "$directory" > /dev/null 2>> error.log
			;;
		gzip)
			tar czf "$output.tar.gz" "$directory" > /dev/null 2>> error.log
			;;
		bzip2)
			tar cjf "$output.tar.bz2" "$directory" > /dev/null 2>> error.log
			;;
		*)
			log_error "Invalid compression algorythm: $compression"
			exit 1
			;;
		esac
	}

	#Find correct output based on compression
	if [[ $output == *.tar.gz ]]; then
		file="$output"
	elif [[ $output == *.tar.bz2 ]]; then
		file="$output"
	else 
		file="$output"
	fi

	#encript using openssl
	openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.enc" > /dev/null 2>>error.log
	if [[ $? -eq 0 ]]; then
		rm "$file"
	else
		log_error "Encription failed"
		exit 1
	fi
     }

#parse commend line argument

 directory=$1
 compression=$2
 output=$3

#check if all required arguments are provided
if [[ -z "$directory" || -z "$compression" || -z "$output" ]]; then
       log_error "Missing required argument: directory, compression or output file name"
       echo "Usage: ./backup.sh <directory> <compression> <output>"
       exit 1
fi

#perform backup and encription

perform_backup "$directory" "$compression" "$output"
encrypt_backup "$output"
