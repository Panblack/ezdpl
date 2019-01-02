#!/bin/bash
# Auto pull new commit, build & deploy. 
build_and_deploy() {
  local _project_path=$1
  local _target_path=$2
  local _project_name=$3
  if [[ ! -d $_project_path ]] || [[ ! -d $_target_path ]]; then
      echo "Project path or target path does not exist."
      return 1
  fi
  echo "$_project_path"
  cd $_project_path
  if ! _pull_info=`git pull 2>&1` ; then
      echo "$_pull_info"
      return 1
  fi

  if echo "$_pull_info" |grep "Already up-to-date." ; then
    echo "No new commit."
    return 1
  fi

  if mvn clean package | grep "BUILD SUCCESS" ; then
    /bin/cp ./target/${_project_name}.?ar $_target_path
    echo "Build & Deploy OK !"
  else
    echo "Build FAIL !"
  fi
  echo 
}

# Samples 
echo proj1
build_and_deploy /home/dev1/projects/proj1 /opt/app/tomcat1/webapps proj1
echo proj2
build_and_deploy /home/dev2/projects/proj2 /opt/app/tomcat1/webapps ROOT
echo

