#!/usr/bin/bash

# unityEditor.sh - script to run unity Editor at given version with given project with PRIME compatibility layer enabled, offloading
# on discrete GPU
# Installation guidelines can be found at https://download.nvidia.com/XFree86/Linux-x86_64/435.21/README/primerenderoffload.html
# 
# Created by Jakub Duchniewicz j.duchniewicz@gmail.com

UNITY_EDITOR_VERSION=""
PROJECT_NAME=""
VK_COMMAND="__NV_PRIME_RENDER_OFFLOAD=1"
ABSOLUTE_PATHS=""
DEFAULT_EDITOR=""

SCRIPTNAME="$(basename $0)"

list_editors()
{
    echo "$UNITY_EDITOR_LOCATION"
    if [ -z "$UNITY_EDITOR_LOCATION" ] ; then echo "Please set UNITY_EDITOR_LOCATION PATH variable to folder containing Unity Editor versions" >&2 ; exit 1; fi
    echo "Available editor versions:"
    for file in `find "$UNITY_EDITOR_LOCATION" -maxdepth 1 -type d`
    do
        echo "$(basename "$file")"
   done
   echo $'\n'
}

list_projects()
{
    if [ -z "$UNITY_PROJECTS_LOCATION" ] ; then echo "Please set UNITY_PROJECTS_LOCATION PATH variable to folder containing Unity Editor versions" >&2 ; exit 1; fi
    echo "Available projects:"
    for file in `find "$UNITY_PROJECTS_LOCATION" -maxdepth 1 -type d`
    do
        echo "$(basename "$file")"
   done
   echo $'\n'
}

list()
{
    local LIST_CHOICE="$1"
    if [ -z "$LIST_CHOICE" ] ; then echo "No arguments passed for --list parameter" >&2 ; exit 1; fi
    if [ "$LIST_CHOICE" == "editors" ]
    then
        list_editors
    elif [ "$LIST_CHOICE" == "projects" ]
    then
        list_projects
    elif [ "$LIST_CHOICE" == "both" ]
    then
        list_editors
        list_projects
    else 
        echo "Wrong arguments passed for --list parameter" >&2 ; exit 1 
    fi
}

default_editor()
{
    # find latest editor version name
    UNITY_EDITOR_VERSION=$(ls "$UNITY_EDITOR_LOCATION" | sort -rn | head -1)
    echo "Using default editor: ""$UNITY_EDITOR_VERSION"

}

last_editor()
{
    UNITY_EDITOR_VERSION=$(ls "$UNITY_EDITOR_LOCATION" -tu | head -1)
    echo "Using last used editor: ""$UNITY_EDITOR_VERSION"
}

last_project()
{
    PROJECT_NAME=$(ls "$UNITY_PROJECTS_LOCATION" -tu | head -1)
    echo "Using last used project: ""$PROJECT_NAME"
}

help()
{
    cat<<EOH
Usage: $SCRIPTNAME [options]

-h, --help                                          get this help
-s, --source <Unity Editor Version>|default|last    load editor version, must specify project, or default|last opened version
-n, --name <Project Name>|last                      load project name, or last opened project
-d, --default                                       load default editor version with default rendering (Vulkan)
-l, --list editors|projects|both                    list available editors|projects|both versions
-o, --opengl                                        render using OpenGL
-a, --absolute                                      use absolute paths

 Before launching, UNITY_EDITOR_LOCATION and UNITY_PROJECTS_LOCATION PATH variables should be set if
 --absolute option is not chosen, when specifying editor source, project name or listing
 available editor versions
EOH
    exit
}

OPTS=$(getopt -n unityEditor -o s:n:l:hdoa --long source:,name:,list:,help,default,opengl,absolute -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1; fi
 
#-- "$OPTS" # this is needed for ending stream, however it is deemed unsafe
eval set -- "$OPTS"

while true; do
    case "$1" in
            -s|--source) UNITY_EDITOR_VERSION="$2"; shift 2 ;;
            -n|--name) PROJECT_NAME="$2"; shift 2 ;;
            -l|--list) list "$2"; exit 0 ;;
            -o|--opengl) VK_COMMAND=""; shift ;;
            -a|--absolute) ABSOLUTE_PATHS=1; shift ;;
            -d|--default) DEFAULT_EDITOR=1; shift ;;
            -h|--help) help ;;
            --) shift; break ;;
            *) echo "Error: $1"; exit 1 ;;
    esac
done

# Set UnityEditor version
# cannot set both editor version and call with default one
echo "$DEFAULT_EDITOR"
if [ -z "$UNITY_EDITOR_VERSION" ] 
then 
    if [ -z "$DEFAULT_EDITOR" ]
    then
        echo "Must specify at least one of -s/-d parameters" >&2 ; exit 1
    else
        default_editor
    fi
elif [ -n "$DEFAULT_EDITOR" ] ; then echo "Cannot specify both -s/-d parameters" >&2 ; exit 1 ;
else # check if parameter is 'default' or 'last'
    if [ "$UNITY_EDITOR_VERSION" == "default" ] ; then default_editor ;
    elif [ "$UNITY_EDITOR_VERSION" == "last" ] ; then last_editor ;
    else echo "Using editor: ""$UNITY_EDITOR_VERSION" ; fi
fi

# Set Unity project choice
if [ -z "$PROJECT_NAME" ]
then
    echo "Must specify project name" >&2 ; exit 1
else # check if parameter is 'last'
    if [ "$PROJECT_NAME" == "last" ] ; then last_project ;
    else  echo "Loading project: ""$PROJECT_NAME" ; fi
fi

UNITY_EDITOR_PATH=""
UNITY_PROJECT_PATH=""
# Finally launch editor with given project with chosen parameters
if [ -z "$ABSOLUTE_PATHS" ]
then 
    UNITY_EDITOR_PATH="$UNITY_EDITOR_LOCATION/$UNITY_EDITOR_VERSION"
    UNITY_PROJECT_PATH="$UNITY_PROJECTS_LOCATION/$PROJECT_NAME"
else
    UNITY_EDITOR_PATH="$UNITY_EDITOR_VERSION"
    UNITY_PROJECT_PATH="$PROJECT_NAME"
fi

echo "Using environment variable: ""$VK_COMMAND"
env "$VK_COMMAND" "$UNITY_EDITOR_PATH"/Editor/Unity -projectPath "$UNITY_PROJECT_PATH"

exit 0   
