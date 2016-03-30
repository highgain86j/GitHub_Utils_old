#!/bin/bash


uauth=$1
pauth=$2
infauth=${uauth}:${pauth}

scr_dir=$(cd $(dirname $0) && pwd)

cd ${scr_dir}

clone_dir=GitHub
clone_dir_full=${scr_dir}/../${clone_dir}


acnt_prvt=${uauth}
#acnt_extl="kicad-jp"
acnt_extl="kicad-jp KiCad"

acnt_ofcl="${acnt_prvt} ${acnt_extl}"
#acnt_ofcl="${acnt_extl}"

filedate=`date +%Y%m%d`
repofext=repos
listfext=list
rejectext=reject
acceptext=accept
addflg=add
delflg=del
sffxprvt=private_${filedate}.${repofext}
sffxfork=fork_${filedate}.${repofext}
sffxsrc=source_${filedate}.${repofext}

sffxpendadd=pending_${addflg}_${filedate}.${repofext}
sffxacceptadd=${addflg}.${acceptext}
sffxrejectadd=${addflg}.${rejectext}

sffxpenddel=pending_${delflg}_${filedate}.${repofext}
sffxacceptdel=${delflg}.${acceptext}
sffxrejectdel=${delflg}.${rejectext}

sffxdir=repos.d

penddir=pending.d

addpendf=${scr_dir}/${penddir}/fork_pending_${addflg}.${repofext}
delpendf=${scr_dir}/${penddir}/fork_pending_${delflg}.${repofext}


red=31
green=32
yellow=33
blue=34

function echo_red {
	color=31
	echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_green {
	color=32
	echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_yellow {
	color=33
	echo -e "\033[0;${color}m${1}\033[0;39m"
}

function echo_blue {
	color=34
	echo -e "\033[0;${color}m${1}\033[0;39m"
}

function gitupdate {
	echo_green "### Looking for repositories to be forked... ###"

	for opmode in add del
		do
		if [ ${opmode} = add ]
			then
				opfile=${addpendf}

		elif [ ${opmode} = del ]
			then
				opfile=${delpendf}
		else
			echo ""
		fi

		if [ ! -e ${penddir} ];
			then
				echo ${penddir}" does not exist. Creating it now."
				mkdir ${penddir}
		fi

		if [ ! -e ${opfile} ];
			then
				echo ${opfile}" does not exist. Creating it now."
				touch ${opfile}
		fi

		cat ${opfile} | grep -v -e '^\s*#' -e '^\s*$' > ${tmp_0}
		cat ${opfile} | grep -e '^\s*#' > ${tmp_1}
		cat ${tmp_1} > ${opfile}

		if [ ${opmode} = add ]
			then
				echo "   Forking the repositories approved after the last session ( specified in "`echo_yellow ${opfile}`" )."
				for source in `cat ${tmp_0}`
					do
					sourceowner=`echo ${source} | awk -F, '{print $1}'`
					sourcerepos=`echo ${source} | awk -F, '{print $2}'`
					echo "> Found;"
					echo ${source}
					echo "> "${sourceowner}"/"${sourcerepos}" successfully forked to "`curl -u ${infauth} -X POST https://api.github.com/repos/${sourceowner}/${sourcerepos}/forks 2> /dev/null | jq '.full_name' | sed -e s/\"//g`
				done
				echo ""
		elif [ ${opmode} = del ]
			then
				echo "   Deleting the repositories approved after the last session ( specified in "`echo_yellow ${opfile}`" )."
				for deltar in `cat ${tmp_0}`
					do
					deltarrepos=`echo ${deltar} | awk -F, '{print $2}'`
					echo "> Found;"
					echo ${deltar}
					echo "> Issueing command;"
					curl -X DELETE -u ${infauth} https://api.github.com/repos/${acnt_prvt}/${deltarrepos} 2> /dev/null
				done
				echo ""
		else
			echo ""
		fi
		echo "   (Paused for 10sec)"
		sleep 10s
		echo ""
	done
}


function description {
	clear
	echo_green "<<   What this script will do...   >>"
	echo "   You are currently running this script as "`echo_yellow ${acnt_prvt}`" on GitHub."
	echo "   This script will first read the list of repositories under your account ("`echo_yellow ${acnt_prvt}`") and they"
	echo "   will be cloned or pulled - hence bringing them locally to this host and/or keeping them up-to-date."
	echo ""
	echo "   You have also specified other GitHub Accounts as follows;"
	for extacnt in `echo ${acnt_extl}`
		do
		echo_yellow "      "${extacnt}
	done
	echo "   All repositories of these accounts - unless blacklisted - will be added to a Fork-pending list."
	echo "   In that file, pending entries are commented-out, and uncommenting them will make them forked at"
	echo "   the next run of this script."
	echo ""
	echo "   All forked repositories - new or existing - will have their parents' URL specified as upstream, and"
	echo "   this script will try to pull changes from parents, push changes to your forks on GitHub,"
	echo "   hence keeping both local and GitHub repositories up-to-date."
	echo "   This script is intended to be run periodically (once a day is ideal) by task schedulers like cron."
	echo ""
	echo "   This in intended to be run in bash, and assumes that you have access to commands like jq, curl, sed,"
	echo "   awk, grep, cat, sort and uniq - of which all except jq should be already available on most Linux distributions."
	echo ""
	echo "   Have fun!"
	echo ""
	echo ""
	echo ""
	echo ""
	echo "(Proceeding in 10s...)" 
	echo ""
	echo ""
	echo ""
	echo ""
	sleep 10s
}


function mktemps {
	tmp_0=`mktemp`
	tmp_1=`mktemp`
	tmp_2=`mktemp`
	tmp_3=`mktemp`
	tmp_4=`mktemp`
	tmp_5=`mktemp`
	tmp_6=`mktemp`
	tmp_7=`mktemp`
	tmp_8=`mktemp`
	tmp_9=`mktemp`
}


function reposprobe {
	for acnt in ${acnt_ofcl} 
		do

		cp /dev/null ${tmp_0}
		cp /dev/null ${tmp_1}
		cp /dev/null ${tmp_2}
		cp /dev/null ${tmp_3}
		cp /dev/null ${tmp_4}
		cp /dev/null ${tmp_5}
		cp /dev/null ${tmp_6}
		cp /dev/null ${tmp_7}
		cp /dev/null ${tmp_8}
		cp /dev/null ${tmp_9}

		acnt_inf=`curl -G https://api.github.com/search/users \
		--data-urlencode q=${acnt} \
		-H 'application/vnd.github.v3.text-match+json' 2> /dev/null \
		| jq '.items[0] | {type, login}' \
		| sed ':loop; N; $!b loop; ;s/\n//g' \
		| sed -e s/\login//g \
		-e s/\type//g \
		-e s/\"//g \
		-e s/\://g \
		-e s/\{//g \
		-e s/\}//g \
		-e s/\ //g`

		acntatr=`echo ${acnt_inf} | awk -F, '{print $1}'`
		acntn=`echo ${acnt_inf} | awk -F, '{print $2}'`

		case ${acntatr} in
			Organization)    acntt=orgs;;
			User)    acntt=users;;
		esac

		echo_green "### Probing the account type... ###"
		echo "   Account type for "`echo_yellow ${acntn}`" is "`echo_yellow ${acntatr}`" ."
		echo "   Repositories for "`echo_yellow ${acntn}`" ("`echo_yellow ${acntatr}`") should be found at "`echo_yellow https://api.github.com/${acntt}/${acntn}`" and is as follows;" 
		echo "   (This process will take a while.)"
		echo ""
		echo ""

		#sleep 30s

		curl -u ${infauth} https://api.github.com/${acntt}/${acntn}/repos?per_page=100 2> /dev/null | jq '.[].name' > ${tmp_0}
		sed -i -e 's/"//g' ${tmp_0}

		if [ ${acntn} != ${acnt_prvt} ] ;
			then

				reposdir=${scr_dir}/${acntn}.${sffxdir}

				if [ ! -e ${reposdir} ];
					then

						mkdir ${reposdir}

				fi

				repossrc=${reposdir}/${acntn}_${sffxsrc}

				diffadd=${reposdir}/${acntn}_${sffxpendadd}
				acceptadd=${reposdir}/${acntn}_${sffxacceptadd}
				rejectadd=${reposdir}/${acntn}_${sffxrejectadd}

				diffdel=${reposdir}/${acntn}_${sffxpenddel}
				acceptdel=${reposdir}/${acntn}_${sffxacceptdel}
				rejectdel=${reposdir}/${acntn}_${sffxrejectdel}

				echo_green "### Checking for files... ###"
				for touchfile in ${repossrc} ${diffadd} ${acceptadd} ${rejectadd} ${diffdel} ${acceptdel} ${rejectdel} 
					do
					if [ ! -e ${touchfile} ];
						then
							echo "   Missing "`echo_yellow ${touchfile}`" - creating now."
							touch ${touchfile}

					fi
				done
				echo ""


			else

				reposdir=${acntn}.${sffxdir}

				if [ ! -e ${reposdir} ];
					then

						mkdir ${reposdir}

				fi

				reposprv=${reposdir}/${acntn}_${sffxprvt}

				touch ${reposprv}

		fi

		echo_green "### Retrieving repository information... ###"

		for repos in `cat ${tmp_0}`
			do

			reposinfo=`curl -u ${infauth} -G https://api.github.com/repos/${acntn}/${repos} 2> /dev/null \
			| jq '.fork, .name, .owner.login, .ssh_url, .parent.name, .parent.owner.login, .parent.ssh_url' \
			| sed -e s/\"//g`

			#Repository is fork?
			reposinf_1=`echo ${reposinfo} | awk '{print $1}'`

			#Repository name
			reposinf_2=`echo ${reposinfo} | awk '{print $2}'`

			#Repository owner (ID)
			reposinf_3=`echo ${reposinfo} | awk '{print $3}'`

			#Repository git URL
			reposinf_4=`echo ${reposinfo} | awk '{print $4}'`

			#Parent repository name
			reposinf_5=`echo ${reposinfo} | awk '{print $5}'`

			#Parent repository owner (ID)
			reposinf_6=`echo ${reposinfo} | awk '{print $6}'`

			#Parent repository git URL
			reposinf_7=`echo ${reposinfo} | awk '{print $7}'`

			if [ ${reposinf_3} = ${acnt_prvt} ] ;
				then

					if [ ${reposinf_1} = true ] ;
						then

							reposfdir=${reposinf_6}.${sffxdir}

							if [ ! -e ${reposfdir} ];
								then

									mkdir ${reposfdir}

							fi

							reposlist=${scr_dir}/${reposfdir}/${reposinf_6}_${sffxfork}
							reposstrg=${reposinf_6},${reposinf_2},${reposinf_7}

						else

							reposlist=${scr_dir}/${reposprv}
							reposstrg=${reposinf_3},${reposinf_2},${reposinf_4}

					fi

				else

					reposlist=${repossrc}
					reposstrg=${reposinf_3},${reposinf_2},${reposinf_4}

			fi


			echo "   Found;"
			echo_yellow "      "${reposstrg}
			echo "   Added to;"
			echo_yellow "      "${reposlist}
			echo ${reposstrg} >> ${reposlist}
			echo ""
			echo ""

		done

		if [ ${acntn} != ${acnt_prvt} ] ;
			then

				echo ""
				echo_green "### Sorting files... ###"
				if [ ! -e ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxfork} ] ;
					then 
						touch ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxfork}
				fi

				for reposfil in ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxsrc} ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxfork}
					do
					sort -r ${reposfil} > ${tmp_0}
					cat ${tmp_0} > ${reposfil}
					echo "   Sorted;"
					echo_yellow "      "${reposfil}
				done
				echo ""
				echo ""

				cp /dev/null ${tmp_0}
				cp /dev/null ${tmp_1}
				cp /dev/null ${tmp_2}
				cp /dev/null ${tmp_3}
				cp /dev/null ${tmp_4}
				cp /dev/null ${tmp_5}
				cp /dev/null ${tmp_6}
				cp /dev/null ${tmp_7}
				cp /dev/null ${tmp_8}
				cp /dev/null ${tmp_9}

				echo_green "### Summary ###"
				for opmode in add del
					do
					if [ ${opmode} = add ]
						then
							blsfile=${rejectadd}
							wlsfile=${acceptadd}
							infile=${tmp_0}
							pndtmp=${tmp_1}
							blstmp=${tmp_2}
							wlstmp=${tmp_3}
							woktmp=${tmp_4}
							pndfile=${diffadd}
							tpndfile=${addpendf}
							line_1="   <<  Available at "${acntn}"  >>"
							line_2="   <<  Ignored (blacklisted)  >>"
							line_3="   <<  Set to be forked on the next run  >>"
							line_4="   <<  Added to pending list for forking to "${acnt_prvt}"  >>"
							diff ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxsrc} ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxfork} | grep '^<' \
							| sed -e "s/< //g" > ${infile}

					elif [ ${opmode} = del ]
						then
							blsfile=${rejectdel}
							wlsfile=${acceptdel}
							infile=${tmp_5}
							pndtmp=${tmp_6}
							blstmp=${tmp_7}
							wlstmp=${tmp_8}
							woktmp=${tmp_9}
							pndfile=${diffdel}
							tpndfile=${delpendf}
							line_1="   <<  No longer available at "${acntn}"  >>"
							line_2="   <<  Ignored (blacklisted)  >>"
							line_3="   <<  Set to be deleted on the next run  >>"
							line_4="   <<  Added to pending list for deletion from "${acnt_prvt}"  >>"
							diff ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxsrc} ${scr_dir}/${acntn}.${sffxdir}/${acntn}_${sffxfork} | grep '^>' \
							| sed -e "s/> //g" > ${infile}
					else
						echo ""
					fi
		#echo "variables set"
		#echo "opmode is "${opmode}

					cat ${infile} > ${pndtmp}
					##

		#echo "processing blacklist - "${blsfile}
					cp /dev/null ${blstmp}
					cp /dev/null ${woktmp}
					for blsentry in `cat ${blsfile}`
						do
						cat ${pndtmp} | grep ${blsentry}  | grep -v -e '^\s*#' -e '^\s*$' >> ${blstmp}
						cat ${pndtmp} | grep -v ${blsentry} | grep -v -e '^\s*#' -e '^\s*$' > ${woktmp}
						cat ${woktmp} > ${pndtmp}
					done
		#echo "blacklisted: "
		#cat ${blstmp}
		#echo ""
		#echo "listed-out: "
		#cat ${pndtmp}
		#echo ""



		#echo "processing whitelist - "${wlsfile}
					cp /dev/null ${wlstmp}
					cp /dev/null ${woktmp}
					for wlsentry in `cat ${wlsfile}`
						do
						cat ${pndtmp} | grep ${wlsentry}  | grep -v -e '^\s*#' -e '^\s*$' >> ${wlstmp}
						cat ${pndtmp} | grep -v ${wlsentry} | grep -v -e '^\s*#' -e '^\s*$' > ${woktmp}
						cat ${woktmp} > ${pndtmp}
					done
		#echo "whitelisted: "
		#cat ${wlstmp}
		#echo ""
		#echo "listed-out: "
		#cat ${pndtmp}
		#echo ""
					##

					#cat ${wlstmp} >> ${tpndfile}

					echo ${line_1}
					for entry in `cat ${infile}`
						do
							echo_yellow "      "${entry}
					done

					echo ""

					echo ${line_2}
					for entry in `cat ${blstmp}`
						do
							echo_yellow "      "${entry}
					done
					echo ""

					echo ${line_3}
					for entry in `cat ${wlstmp}`
						do
							echo_yellow "      "${entry}
							echo ${entry} >> ${pndfile}
					done
					echo ""

					echo ${line_4}
					for entry in `cat ${pndtmp}`
						do
							echo_yellow "      "${entry}
							echo "#"${entry} >> ${pndfile}
					done

					sort -r ${pndfile} > ${pndtmp}
					uniq ${pndtmp} > ${pndfile}

					echo ""

					echo ""
					echo ""

				done
		fi

			echo ""
			echo ""
			echo ""
			echo ""
	done
}


function gitclone {
	echo_green "### git clone / git sync ###"
	listall=`mktemp`
	buffer=`mktemp`
	if [ ! -e ${clone_dir_full} ]
		then
			echo `echo_yellow ${clone_dir_full}`" does not exist. Creating now."
			mkdir ${clone_dir_full}
	fi
	for clonelst in `ls ${scr_dir}/*.${sffxdir}/*_${sffxfork}` `ls ${scr_dir}/*.${sffxdir}/*_${sffxprvt}`
		do
		cat ${clonelst} >> ${listall}
	done
	for clonelne in `cat ${listall}`
		do
		var_ownerid=`echo ${clonelne} | awk -F, '{print $1}'`
		var_repname=`echo ${clonelne} | awk -F, '{print $2}'`
		var_git_url=`echo ${clonelne} | awk -F, '{print $3}'`
		git_url1="git@github.com:${uauth}/${var_repname}.git"
		git_url2="${var_git_url}"
		gitdir2=${clone_dir_full}/${var_ownerid}
		if [ ! -e ${gitdir2} ]
			then
				mkdir ${gitdir2}
		fi
		cd ${gitdir2}
		if [ ! -e ${var_repname} ]
			then
				echo "Cloning "`echo_yellow ${var_repname}`
				git clone ${git_url1}
				if [ ! "${git_url1}" = "${git_url2}" ]
					then
						cd ${var_repname}
						echo_blue "git remote add upstream "${git_url2}
						git remote add upstream ${git_url2}





						echo_blue ""
						cd ..
				fi
			else
				if [ ! "${git_url1}" = "${git_url2}" ]
					then
						cd ${var_repname}
						echo_blue "git remote -v"
						git remote -v




						echo_blue "git fetch upstream"
						git fetch upstream





						echo_blue "git checkout master"
						git checkout master





						echo_blue "git merge"
						git merge upstream/master





						echo_blue "git push origin master"
						git push origin master





						echo_blue ""
						cd ..
					else
						cd ${var_repname}
						echo_blue "git remote -v"
						git remote -v





						echo_blue "git fetch"
						git fetch





						echo_blue "git merge"






						echo_blue "git push origin master"
						git push origin master





						echo ""
						cd ..
				fi
		fi
	done
	rm ${listall}
	rm ${buffer}
echo ""
cd ${scr_dir}
}


function inittmp {
	cp /dev/null ${tmp_0}
	cp /dev/null ${tmp_1}
	cp /dev/null ${tmp_2}
	cp /dev/null ${tmp_3}
	cp /dev/null ${tmp_4}
	cp /dev/null ${tmp_5}
	cp /dev/null ${tmp_6}
	cp /dev/null ${tmp_7}
}


function repoprocess {
	echo_green "### Writing files... ###"
	for opmode in add del
		do
		if [ ${opmode} = add ]
			then
				wriout=${addpendf}
				suffix=${sffxpendadd}
		elif [ ${opmode} = del ]
			then
				wriout=${delpendf}
				suffix=${sffxpenddel}
		else
			echo "Error."
		fi

		echo "   Writing out to "`echo_yellow ${wriout}`
		echo ""
		#ls *.${sffxdir}/*_${suffix}
		#echo ""
		#echo "Opmode is "${opmode}
		#echo ""
		cp /dev/null ${wriout}

		for pendingf in `ls ${scr_dir}/*.${sffxdir}/*_${suffix}`
			do
			for entline in `cat ${pendingf}`
				do
				#echo ${entline} >> ${wriout}
				echo_yellow "      "${entline}
			done
		done

		sort -r ${wriout} > ${tmp_0}
		uniq ${tmp_0} > ${wriout}

		echo ""
		echo ""
	done
}


function cleanupf {
	echo_green "### Cleaning up... ###"
	for garbage in `ls ${scr_dir}/*.${sffxdir}/*.${repofext}` ${tmp_0} ${tmp_1} ${tmp_2} ${tmp_3} ${tmp_4} ${tmp_5} ${tmp_6} ${tmp_7} ${tmp_8} ${tmp_9}
		do
		echo "   Deleting;"
		echo_yellow "      "${garbage}
		rm ${garbage}
		echo ""
	done
}

description

mktemps

gitupdate

reposprobe

gitclone

inittmp

repoprocess

cleanupf
