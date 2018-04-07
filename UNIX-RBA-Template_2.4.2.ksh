#!/usr/bin/env ksh
#
########## 
# NAME: <Script Name>
#
# PURPOSE: <Purpose Description>
#
# TARGET OS(s): (Example: Solaris(5.8 - 5.11), HP-UX(10.20 - 11.31), AIX(4.3 - 7.X), Suse(10.20 - 11.X), Redhat(4.X - 7.X), and Oracle)
#
# INPUT: (Expected Input)
#
# OUTPUT: (Expected Output)
#
# Original Author(s): <Author(s) Name>
# Additional Author(s): <Author(s) Name>
##########
#
##########
#
# DO NOT MODIFY USAGE START/END LINES!!! This will cause UsageMessage to fail. All
# text between to the 2 lines can be modified as needed.
# SCRIPTNAMEPLACEHOLDER will be replaced by actual script name when displayed via
# UsageMessage.
#
##### USAGE START
#
#NAME
#   SCRIPTNAMEPLACEHOLDER
#
#SYNOPSIS
#   SCRIPTNAMEPLACEHOLDER - This script is not designed to be run from the command line. RBA USE ONLY!!!
#
#COPYRIGHT
##### USAGE END
#
##### COPYRIGHT START
#######################################################################################
#
# (c) Copyright 2015, revised 2016 Hewlett Packard Enterprise Developement LP
#
# Information contained in this document is proprietary and confidential to
# Hewlett Packard Enterprise Development Lp and may not be disclosed to any third
# party without prior written consent from Hewlett Packard Enterprise Development LP
#
#######################################################################################
##### COPYRIGHT END
#
##### MODIFICATION HISTORY:
# MONTH(3 characters only, Mar, Apr, etc.) DAY(XX) YEAR(XXXX) VERSION(X.X.X Major.Minor.Bug notation) Author Name
#   - Modification Information
#
##### End History #####
#
##### Initial function definition
DefineBinary() {
  ### Used to define all binary variables, and set their location
  ### Function specific declarations - Any variables or arrays that are called by all OS's, should be put here
  ### DO NOT MODIFY THIS FUNCTION!!!
  # Common directory locations. DO NOT MODIFY!!!
  CurrentPathDirectories="$(IFS=: ; printf -- "\"%s\/\"\n" ${PATH})"
  set -A CommonBinaryDirectoryLocations "/sbin/" "/usr/sbin/" "/bin/" "/usr/bin/" "/usr/local/sbin/" "/usr/local/bin/" ${CurrentPathDirectories} ${CustomPathDirectories[*]}

  # Function specific declarations
  set -A CurrentInput "$@"
  DefineBinaryErrorStatus=0

  # Initialize arrays, based upon type function was called with
  case ${CurrentInput[*]} in
    INITIALIZE )
      # Common binary list. DO NOT MODIFY!!!
      set -A CurrentBinaryList uname grep egrep awk sed cut hostname ps cat date who wc ls tr renice cp rm diff find nice sort sleep tail head uptime chmod uniq df id perl

      # Type specific variables
      CurrentInputMode=0
    ;;

    *NOFAIL* )
      # Requested os/os version specific binary, but will not stop the script. Used if command needed, is not part of the common list, but can only have one binary
      set -A CurrentBinaryList "${CurrentInput[@]}"

      # Type specific variables
      CurrentInputMode=1

      # Check number of current inputs, and fail if greater than 2. This mode only supports 1 binary
      if [[ ${#CurrentInput[@]} -ne 2 ]]; then
        set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Too many binaries being called, only one binary is allowed with the NOFAIL switch!!! - Current input: ${CurrentInput[*]}"
        RBAExitStatus=3
        FinalReportOutput
      fi
    ;;

    * )
      # Requested os/os version specific binary, any missing binary will stop the script. Used if command needed, is not part of the common list, multiple binaries can be defined at once
      set -A CurrentBinaryList "${CurrentInput[@]}"

      # Type specific variables
      CurrentInputMode=0
    ;;
  esac

  ### Function main body
  # Define and check executibility, for binaries used throughout the script, along with any specialized binaries(on a per needed bases)
  # NOTE: Specialized is defined as any binary that is either unique to a particular OS/OS Version, or is known to not exist for all server builds
  for CurrentBinary in "${CurrentBinaryList[@]}"; do
    # Take current binary input, and create an upper case version of it's name. The upper case variable name will be used to call the fully pathed binary
    typeset -u CurrentBinaryUpperCaseName="${CurrentBinary##*/}"
    CurrentBinaryInitializationStatus=0

    # Checks current input for a leading "/", if found will check input as is, as the leading "/" denotes that the current entry is fully pathed already
    case "${CurrentBinary%%/*}" in
      ?([^/.*]) )
        if [[ -x "${CurrentBinary}" ]]; then
          eval "${CurrentBinaryUpperCaseName}=${CurrentBinary}"
          CurrentBinaryInitializationStatus=1
        fi
      ;;

      # This line handles special modifiers(ie, NOFAIL, etc)
      *NOFAIL* )
        continue
      ;;

      * )
        # This will check current path for existence of binary, and verify it's executability
        for CurrentDirectoryLocationInput in ${CommonBinaryDirectoryLocations[*]}; do
          if [[ -x "${CurrentDirectoryLocationInput}${CurrentBinary}" ]]; then
            eval "${CurrentBinaryUpperCaseName}=${CurrentDirectoryLocationInput}${CurrentBinary}"
            CurrentBinaryInitializationStatus=1
            break
          fi
        done
      ;;
    esac

    # Collects a list of binaries not found, and reports it back to user
    if [[ ${CurrentBinaryInitializationStatus} -eq 0 ]]; then
      set -A MissingBinaryList -- "${MissingBinaryList[@]}" ${CurrentBinary}
    fi
  done

  # Binary error handling
  if [[ ! -z ${MissingBinaryList} && ${CurrentInputMode} -eq 0 ]]; then
    set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Unable to find all binaries needed to run script!!! - Missing binaries: ${MissingBinaryList[*]}"
    RBAExitStatus=3

    # Combine reports already generated at time of script being aborted/killed into the standard wfan output
    set -A CollectedSummaryReports -- "${ReportSummary[@]}"

    # Call final report function to output any salvagable reports and/or additional messages
    FinalReportOutput

  elif [[ ! -z ${MissingBinaryList} && ${CurrentInputMode} -eq 1 ]]; then
    DefineBinaryErrorStatus=1
  fi

  # Clear used arrays and variables
  unset CurrentBinaryList CurrentBinary CurrentBinaryUpperCaseName CurrentDirectoryLocationInput MissingBinaryList
}

### Initialize common binaries. These are defined as binaries needed throughout the script, and are considered common to all OS's/OS Versions
DefineBinary INITIALIZE

##### Global variable declarations
CurrentHostname="$(${HOSTNAME})"
CurrentDateTime=$(${DATE} '+%m/%d/%Y %H:%M:%S')
ScriptVersion="0.0.0"
TemplateVersion="2.4.2"
ScriptName=$(print ${0##*/})
RBAExitStatus=0

##### Custom global variable declarations

##### Generates the usage message, using the information between USAGE START/END at top of script
UsageMessage() {
  ${SED} -n '/^#\{1,\} USAGE START$/,/^#\{1,\} USAGE END$/p' $0 2>/dev/null | ${SED} '/^#\{1,\} USAGE [S|E].*/d;s/#//g' 2>/dev/null | ${SED} "s/SCRIPTNAMEPLACEHOLDER/${ScriptName}/g" 2>/dev/null
  ${SED} -n '/^#\{1,\} COPYRIGHT START$/,/^#\{1,\} COPYRIGHT END$/p' $0 2>/dev/null | ${SED} '/^#\{1,\} COPYRIGHT [S|E].*/d;/#[\t ]*#$/d;s/#//g; ' 2>/dev/null

  exit 0
}

##### Determine if root user is running script
if [[ $(${ID} 2>/dev/null | ${AWK} '{print $1}' 2>/dev/null | ${SED} 's/.*(//;s/).*//' 2>/dev/null) != "root" ]]; then
  if [[ $(${WHO} am i 2>/dev/null | ${AWK} '{print $1}' 2>/dev/null) != "root" ]]; then
    set -A AdditionalMessages "Script must be run by root!!!"
    RBAExitStatus=1
  fi
fi

##### OS discovery and initialization
OSName=$(${UNAME} 2>/dev/null)

case ${OSName} in 
  HP-UX )
    # Custom binary declaration
    DefineBinary umask

    # Set umask setting - This will help prevent unauthorized users from reading any temp files created by script
    ${UMASK} 0077 2>/dev/null

    # Define OS Version and Release
    ${UNAME} -r 2>/dev/null | ${SED} 's/B\.//;s/\./ /' 2>/dev/null | read OSVersion OSRelease
  ;;

  AIX )
    # Custom binary declaration
    DefineBinary umask

    # Set umask setting - This will help prevent unauthorized users from reading any temp files created by script
    ${UMASK} 0077 2>/dev/null

    # Define OS Version and Release
    ${UNAME} -a 2>/dev/null | ${AWK} -F. '{print $4, $3}' 2>/dev/null | read OSVersion OSRelease
  ;;

  SunOS )
    # Custom binary declaration
    DefineBinary umask

    # Set umask setting - This will help prevent unauthorized users from reading any temp files created by script
    ${UMASK} 0077 2>/dev/null

    # Define OS Version and Release
    ${UNAME} -r 2>/dev/null | ${AWK} -F. '{print $1, $2}' 2>/dev/null | read OSVersion OSRelease
  ;;

  Linux )
    # Set umask setting - This will help prevent unauthorized users from reading any temp files created by script
    # NOTE: Linux does not have a separate umask binary, and is built into the shell, so it is not defined in the normal manner
    umask 0077 2>/dev/null

    if [[ -s /etc/oracle-release ]]; then
      OSName="ORACLE"

      # Define OS Version and Release
      ${GREP} -i "release" /etc/oracle-release 2>/dev/null | ${SED} 's/.*release //;s/ (.*$//;s/\./ /' 2>/dev/null | read OSVersion OSRelease

    elif [[ -s /etc/SuSE-release ]]; then
      OSName="SUSE"

      # Define OS Version and Release
      OSVersion=$(${GREP} -i "version" /etc/SuSE-release 2>/dev/null | ${AWK} -F= '{print $2}' 2>/dev/null | ${SED} 's/ *//g' 2>/dev/null)

    elif [[ -s /etc/redhat-release ]]; then
      OSName="REDHAT"

      # Define OS Version and Release
      ${GREP} -i "release" /etc/redhat-release 2>/dev/null | ${SED} 's/.*release //;s/ (.*$//;s/\./ /' 2>/dev/null | read OSVersion OSRelease

    else
      set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Cannot determine OS, or script is not implemented for this platform!!!"
      RBAExitStatus=2
    fi
  ;;

  * )
    set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Cannot determine OS, or script is not implemented for this platform!!!"
    RBAExitStatus=2
  ;;
esac

##### Initial Option handling
# Handle all options
while getopts ":Vh" Option; do
  case ${Option} in
    V )
      print -- "${ScriptVersion}" 2>/dev/null
      exit 0
    ;;

    h|* )
      UsageMessage
    ;;
  esac
done
shift $((${OPTIND} -1))

##### Killed script cleanup - DO NOT MODIFY THIS LINE OR THE CALLED FUNCTION!!!
trap 'TrapFunctionCall' INT TERM

TrapFunctionCall() {
  # Add line to additional messages to let user know script did not complete as expected
  set -A AdditionalMessages -- "${AdditionalMessages[@]}" "${ScriptName} Died, Aborted, or was Killed !!!"

  # Combine reports already generated at time of script being aborted/killed into the standard wfan output
  set -A CollectedSummaryReports -- "${ReportSummary[@]}"

  # Over-ride current RBA exit status
  RBAExitStatus=2

  # Call final report function to output any salvagable reports and/or additional messages
  FinalReportOutput
}

##### Change script priority - Sets the script priority to a higher number, as this will try to mitgate any impact the script has on the performance of the server. 
${RENICE} +20 $$ 1>/dev/null 2>&1

##### Defined RBA exit status's - DO NOT MODIFY!!!
set -A GenerateRBAExitStatusMessage "success" "failure" "diagnose" "categorized"

##### Global defined functions - All functions that interact with multiple tests or functions should go here
Divider() {
  # Function specific declarations
  DividerType="$1"

  # Local main function body
  case ${DividerType} in
    1 )
      print -- "==============================================================================" 2>/dev/null
    ;;

    2 )
      print -- "------------------------------------------------------------------------------" 2>/dev/null
    ;;
  esac
}

FinalReportOutput() {
  ##### Generates the final report - DO NOT MODIFY!!!
  # WFAN Header
  print -- "RBA script stdout" 2>/dev/null
  print -- "Script Version: ${ScriptVersion}" 2>/dev/null
  print -- "Template Version: ${TemplateVersion}\n" 2>/dev/null
  print -- "WFAN=\"" 2>/dev/null

  # Verify that CollectedSummaryReports is not empty. If empty, set RBAExitStatus to 3(categorized), and send message to STDIO(screen normally)
  # Note: The AdditionalMessages empty check is added to prevent a "no report summary" error message when there are messages present in AdditionalMessages
  if [[ ! -z ${CollectedSummaryReports[*]}  || ! -z ${AdditionalMessages[*]} ]]; then

    # Send all report information to STDIO(screen normally)
    for CurrentLine in "${CollectedSummaryReports[@]}"; do
      print -- "${CurrentLine}" 2>/dev/null
    done

  else
    print -- "\n$(Divider 1)" 2>/dev/null
    print -- "\nERROR: No report summary data found!!!\n" 2>/dev/null
    print -- "This message should never be seen. Please check/fix your code, and re-run script\n" 2>/dev/null
    print -- "$(Divider 1)\n" 2>/dev/null
    RBAExitStatus=3
  fi

  # Additional script messages - This will be used to pass along any messages or status's that should be captured, but that does not fall within
  # the standard report output display. Examples: Any error messages, including binary(s) not found, insuffient disk space, etc
  if [[ ! -z ${AdditionalMessages} ]]; then
    print -- "\n##### Additional information #####" 2>/dev/null

    for CurrentLine in "${AdditionalMessages[@]}"; do
      print -- "${CurrentLine}" 2>/dev/null
    done
  fi

  # WFAN Footer
  print -- "\"" 2>/dev/null

  ##### RBA exit status
  print -- "RBA ${GenerateRBAExitStatusMessage[${RBAExitStatus}]}" 2>/dev/null

  # Clean up
  unset CollectedSummaryReports AdditionalMessageOutput

  ##### Script exit status - DO NOT MODIFY!!! This should always be set to '0'
  exit 0
}

DiskSpaceCheck() {
  ##### Check disk space threshold for inputted directory 
  # Function specific declarations
  CurrentInput="$1"
  CurrentDiskSpaceThreshold="$2"

  ### Function main body
  # Check if directory exists, and exit script if it does not
  if [[ -a "${CurrentInput}" ]]; then

    # Check current directory for necessary space
    case ${OSName} in 
      HP-UX|AIX|ORACLE|SUSE|REDHAT )
        if [[ $(${DF} -kP "${CurrentInput}" 2>/dev/null | ${TAIL} -1 2>/dev/null | ${AWK} '{temp=($4) / (1024) ; printf "%0.0f\n", temp}' 2>/dev/null) -le ${CurrentDiskSpaceThreshold} ]]; then
          set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Not enough disk space in directory: ${CurrentInput}\nYou must have at least ${CurrentDiskSpaceThreshold}MB's free!!!"
          return 1
        fi
      ;;

      SunOS )
        if [[ $(${DF} -k "${CurrentInput}" 2>/dev/null | ${TAIL} -1 2>/dev/null | ${AWK} '{temp=($4) / (1024) ; printf "%0.0f\n", temp}' 2>/dev/null) -le ${CurrentDiskSpaceThreshold} ]]; then
          set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Not enough disk space in directory: ${CurrentInput}\nYou must have at least ${CurrentDiskSpaceThreshold}MB's free!!!"
          return 1
        fi
      ;;
    esac

  else
    set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Directory ${CurrentInput} does not exist!!!\nUnable to complete disk space check!!!"
    return 1
  fi
}

PermissionsCalculator() {
  ### Calculate permission of inputted file/directory, including special permissions(sticky bit)
  # Function specific declarations
  CurrentInput="$(${LS} -lLd "$1" 2>/dev/null | ${AWK} '{print substr($0,2,9)}' 2>/dev/null)"

  ### Function main body
  # Owner, Group, World permission handling
  OwnerPermissions=$(($(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c1-3 2>/dev/null | ${TR} '\-rwxSs' 042101 2>/dev/null | ${SED} 's/./&+/g;s/+$//' 2>/dev/null)))
  GroupPermissions=$(($(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c4-6 2>/dev/null | ${TR} '\-rwxls' 042101 2>/dev/null | ${SED} 's/./&+/g;s/+$//' 2>/dev/null)))
  WorldPermissions=$(($(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c7-9 2>/dev/null | ${TR} '\-rwxTt' 042101 2>/dev/null | ${SED} 's/./&+/g;s/+$//' 2>/dev/null)))

  # Owner, Group, World special(modes) permission handling
  OwnerSpecialPermissions=$(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c3 2>/dev/null | ${TR} '\-Ss' 044 2>/dev/null)
  GroupSpecialPermissions=$(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c6 2>/dev/null | ${TR} '\-ls' 022 2>/dev/null)
  WorldSpecialPermissions=$(print -- "${CurrentInput}" 2>/dev/null | ${CUT} -c9 2>/dev/null | ${TR} '\-Tt' 011 2>/dev/null)
  SpecialPermissions=$((${OwnerSpecialPermissions}+${GroupSpecialPermissions}+${WorldSpecialPermissions}))

  # Output Results
  print -- "${SpecialPermissions}${OwnerPermissions}${GroupPermissions}${WorldPermissions}" 2>/dev/null
}

PortConnectivityCheck() {
  ### Tests whether a port is open on the target system. Uses normal routing table for network adapter used
  # Function specific declarations
  CurrentTargetAddress="$1"
  CurrentTargetPort="$2"

  ### Function main body
  # Custom binary declaration
  DefineBinary NOFAIL /opt/opsware/agent/bin/python

  if [[ $? -eq 0 ]]; then
    ${PYTHON} -c "import socket,sys; SocketTest=socket.socket(socket.AF_INET, socket.SOCK_STREAM); SocketTest.connect((sys.argv[1], int(sys.argv[2]))); SocketTest.shutdown(2)" ${CurrentTargetAddress} ${CurrentTargetPort} 1>/dev/null 2>&1
    return $?

  else
    return 2
  fi
}

TempFileCleanUp() {
  ### Clean up input files, and report any issues
  # Function specific declarations
  CurrentInputFile="$1"

  ### Local main function body
  ${RM} "${CurrentInputFile}" 2>/dev/null

  # Verify Clean up
  if [[ -a "${CurrentInputFile}" ]]; then
    set -A AdditionalMessages -- "${AdditionalMessages[@]}" "Could not remove ${CurrentInputFile} - Manual removal required"
    RBAExitStatus=2
  fi
}

##### OS defined test functions - All tests should be defined here. Tests are not order specific, and can be added in any order
RBA_AUTOMATION_TEST() {
  ### Function specific declarations - Any variables or arrays that are called by all OS's, should be put here

  ### Function specific common commands - Sub functions that are called by all OS's, should be put here

  ### OS/OS Version defined commands

  # setting header
  set -A ReportSummary -- "${ReportSummary[@]}" "${MarkHeader}HEADER:"
  set -A ReportSummary -- "${ReportSummary[@]}" "Executing command: ${COMMAND}"
  set -A ReportSummary -- "${ReportSummary[@]}" "${MarkOutput}Output:"

  # show results
  set -A ReportSummary -- "${ReportSummary[@]}" "$(printf -- "%s\n" "${ARRAY[@]}" 2>/dev/null | ${HEAD} -n 5 2>/dev/null)"
  set -A ReportSummary -- "${ReportSummary[@]}" "${MarkSumary}"
  set -A ReportSummary -- "${ReportSummary[@]}" "Total count array entries: ${#ARRAY[@]}"
  set -A ReportSummary -- "${ReportSummary[@]}" "Need manual check. RBA script Aborting..."

  case ${OSName} in
    HP-UX )
    ;;

    REDHAT )
    ;;

    SUSE )
    ;;

    ORACLE )
    ;;

    AIX )
    ;;

    SunOS )
    ;;

    * )
      set -A AdditionalMessages -- "${AdditionalMessages[@]}" "${OSName} not being handled currently by script."
      RBAExitStatus=3
    ;;
  esac 

  ### Add report summary's to final report array
  set -A CollectedSummaryReports -- "${ReportSummary[@]}"

  ### Post test clean up
  unset ReportSummary
}

##### Run Body - DO NOT MODIFY
# Run RBA test function
RBA_AUTOMATION_TEST 2>/dev/null

##### Final report output
FinalReportOutput
