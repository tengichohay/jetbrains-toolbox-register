#!/bin/bash
net session > /dev/null 2>&1
if ! [ $? -eq 0 ]; then
  echo "Please run shell with administrator"
  read -rsp "Press any key to exit..." -n 1
  exit
fi

toolBoxPath="C:/Users/$USERNAME/AppData/Local/JetBrains/Toolbox"
# Declare and initialize appInstall as an associative array
declare -A appInstall

# Get list of app installs
for dirG in "$toolBoxPath/apps/"*; do
  for dirH in "$dirG"/*; do
    if [ "${dirH##*/}" == "ch-0" ]; then
      appInstall["${dirG##*/}"]="$toolBoxPath/apps/${dirG##*/}/${dirH##*/}"
    fi
  done
done

registerExe() {
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\shell\\$1\\command /ve /d \"\"\"${2////\\}\"\" \"\"%1\"\"\" /f" > /dev/null 2>&1
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\shell\\$1 /ve /d \"Open Folder as $1 Project\" /f" > /dev/null 2>&1
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\Background\\shell\\$1\\command /ve /d \"\"\"${2////\\}\"\" \"\"%V\"\"\" /f" > /dev/null 2>&1
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\Background\\shell\\$1 /ve /d \"Open Folder as $1 Project\" /f" > /dev/null 2>&1
}

registerIcon() {
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\shell\\$1 /v Icon /d \"\"\"${2////\\}\"\"\",0\"\" /f" > /dev/null 2>&1
  cmd.exe /c "REG ADD HKEY_CLASSES_ROOT\\Directory\\Background\\shell\\$1 /v Icon /d \"\"\"${2////\\}\"\"\",0\"\" /f" > /dev/null 2>&1
}

# Process app installs
for key in "${!appInstall[@]}"; do
  # Check if it is a folder
  if [ -d "${appInstall[$key]}" ]; then
    for dirI in "${appInstall[$key]}"/*; do
      #Check if it is a folder and not a plugin folder
      if [ -d "$dirI" ] && [[ "$(basename "$dirI")" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        for file in "$dirI/bin"/*; do
          if [ -f "$file" ]; then
            baseName="$(basename "$file")"
            if [[ $baseName =~ .*64\.exe$ ]]; then
              registerExe "$key" "$file"
              echo RegisterExe: $baseName 
            fi
            if [[ $baseName =~ .*\.ico$ ]]; then
              registerIcon "$key" "$file"
              echo RegisterIcon: $baseName 
            fi
          fi
        done
      fi
    done
  fi
done
read -rsp "Resgistration completed!!!. Press any key to exit..." -n 1
