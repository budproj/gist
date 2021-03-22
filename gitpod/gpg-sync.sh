#!/usr/bin/env bash

# WHAT DOES THIS SCRIPT DO
# -------------------------------------------------------------------------------------------------
#
# It checks if you have all proper requirements and them set your GPG directory, adding to your
# Git config the GPG key you're willing to sign your work to.
#
# REQUIREMENTS
# -------------------------------------------------------------------------------------------------
#
# To execute this script, you must have the following environment variables set:
# - GNUPG: containing a base64 string of your ~/.gnupg folder
# - #GNUPG_KEY_ID: containing the ID of the GPG key you will use
#
# To generate the first one, you can run the following code:
# cd ~ && tar -czvf - ./.gnupg | base64 -w 0
#
# DEPENDENCIES
# -------------------------------------------------------------------------------------------------
# 
# To run this script, you must have the following tools installed:
# - bash 4.x.x
# - tar 1.x.x
# - git 2.x.x

# Functions
# -------------------------------------------------------------------------------------------------

function validate_requirements {
  validate_environment_variables
  validate_dependencies
}

function validate_environment_variables {
  validate_gnupg_environment_variable
  validate_gnupg_key_id_environment_variable
}

function validate_gnupg_environment_variable {
  if [ -z "${GNUPG}" ]; then
    throw_error "You need to define a GNUPG environment variable"
  fi
}

function validate_gnupg_key_id_environment_variable {
  if [ -z "${GNUPG_KEY_ID}" ]; then
    throw_error "You need to define a GNUPG_KEY_ID environment variable"
  fi
}

function validate_dependencies {
  validate_bash_dependency
  validate_tar_dependency
  validate_git_dependency
}

function validate_bash_dependency {
  major_version="$(bash --version | head -1 | cut -d ' ' -f 4 | cut -d '.' -f 1)"
  min_major_version="4"

  if [ "${major_version}" -lt "${min_major_version}" ]; then
    throw_error "Your bash major version must be ${min_major_version} or greater"
  fi
}

function validate_tar_dependency {
  major_version="$(tar --version | head -1 | cut -d ' ' -f 4 | cut -d '.' -f 1)"
  min_major_version="1"

  if [ "${major_version}" -lt "${min_major_version}" ]; then
    throw_error "Your tar major version must be ${min_major_version} or greater"
  fi
}

function validate_git_dependency {
  major_version="$(git --version | head -1 | cut -d ' ' -f 3 | cut -d '.' -f 1)"
  min_major_version="2"

  if [ "${major_version}" -lt "${min_major_version}" ]; then
    throw_error "Your git major version must be ${min_major_version} or greater"
  fi
}

function sync_gpg {
  cd ~
  rm -rf .gnupg
  echo $GNUPG | base64 -d | tar --no-same-owner -xzvf -
}

function apply_git_config {
  git config --global user.signingkey $GNUPG_KEY_ID
  git config --global commit.gpgsign true
}

# Helpers
# -------------------------------------------------------------------------------------------------

function throw_error {
  message=$1

  bold=$(tput bold)
  reset=$(tput sgr0)
  red=$(tput setaf 1)

  echo "${bold}${red}Error:${reset}"
  echo "${red}  ${message}${reset}"
  exit 1
}

# Entrypoint
# -------------------------------------------------------------------------------------------------

function main {
  validate_requirements
  sync_gpg
  apply_git_config
}

main
