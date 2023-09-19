#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
 echo -e "\n\n${redColour}[!]${endColour} ${yellowColour}Saliendo...${endColour}\n" 
 tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados :)${endColour}"
    tput cnorm
  else 
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5sum_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5sum_original_value=$(md5sum bundle.js | awk '{print $1}')
    if [ "$md5sum_temp_value" == "$md5sum_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han encontrado actualizaciones${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour}Se han encontrado actualizaciones disponibles${endColour}"
      sleep 2
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
   fi
    tput cnorm
  fi
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por direccion IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de la maquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por el sistema operativo de la maquina${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por Skill${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de Youtube de la resolucion de la maquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function searchMachine(){
  machineName="$1"
    
  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -ve "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  osMachine="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep "so: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')" 
  
  difficultyMachine="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep "dificultad: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')" 

  osColor=""

  difficultyColor=""

  if [ "$osMachine" == "Windows" ]; then 
    osColor=$blueColour
  else
    osColor=$greenColour
  fi

  if [ "$difficultyMachine" == "Fácil" ]; then 
    difficultyColor=$turquoiseColour
  elif [ "$difficultyMachine" == "Media" ]; then
    difficultyColor=$purpleColour
  elif [ "$difficultyMachine" == "Difícil" ]; then
    difficultyColor=$yellowColour
  else
    difficultyColor=$redColour
  fi


  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour}${osColor} $machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -ve "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed -E -e "s/(name: )(.*)/${purpleColour}name:${endColour} ${osColor}\2${endColour}/g" \
      -e "s/(ip: )(.*)/${purpleColour}ip:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(so: )(.*)/${purpleColour}so:${endColour} ${osColor}\2${endColour}/g" \
      -e "s/(dificultad: )(.*)/${purpleColour}dificultad:${endColour} ${difficultyColor}\2${endColour}/g" \
      -e "s/(id: )(.*)/${purpleColour}id:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(sku: )(.*)/${purpleColour}sku:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(skills: )(.*)/${purpleColour}skills:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(like: )(.*)/${purpleColour}like:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(youtube: )(.*)/${purpleColour}youtube:${endColour} ${grayColour}\2${endColour}/g" \
      -e "s/(resuelta: )(.*)/${purpleColour}resuelta:${endColour} ${grayColour}\2${endColour}/g" \
# sed -E "s/(name: .*|skills: |ip: |so: |id: |dificultad: |sku: |like: |youtube: |resuelta: )/${purpleColour}&${endColour}/g"
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP(){
  ipAdress="$1"

  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'
  osColor=""

  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  osMachine="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 -A 2 | grep "so: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$osMachine" == "Windows" ]; then
    osColor=$blueColour
  else
    osColor=$greenColour
  fi

  if [ "$machineName" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${osColor} $ipAdress ${endColour}${grayColour}es${endColour} ${osColor}$machineName${endColour}\n"
else
   echo -e "\n${redColour}[!] La direccion IP proporcionada no corresponde a una maquina${endColour}\n"
  fi
}

function getYoutubeLink(){
  machineName="$1"

  osColor=""

  youtubeMachine_link="$(cat bundle.js | awk "/: \"$machineName\"/,/resuelta:/" | grep "youtube:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk 'NF{print $NF}')"

  osMachine="$(cat bundle.js | awk "/: \"$machineName\"/,/resuelta:/" | grep "so: " | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk 'NF{print $NF}')"

  if [ "$osMachine" == "Windows" ]; then
    osColor=$blueColour
  else
    osColor=$greenColour
  fi

  if [ "$youtubeMachine_link" ]; then

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Link de Youtube de la resolucion de la maquina${endColour}${osColor} $machineName${endColour}${grayColour}:${endColour}${purpleColour} $youtubeMachine_link${endColour}\n"
  else  
   echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi

}

function getMachinesDifficulty(){
  difficulty="$1"

  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'
  difficultyColor=""

  machineDifficulty="$(cat bundle.js | iconv -f utf-8 -t ascii//TRANSLIT | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$difficulty" == "Insane" ]; then
    difficultyColor=$redColour
  elif [ "$difficulty" == "Media" ]; then
    difficultyColor=$purpleColour
  elif [ "$difficulty" == "Dificil" ]; then
    difficultyColor=$yellowColour
  else
    difficultyColor=$turquoiseColour
  fi

if [ "$machineDifficulty" ]; then
   echo -e "\n${grayColour}[+] Maquinas con dificultad ${endColour}${difficultyColor}$difficulty${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | iconv -f utf-8 -t ascii//TRANSLIT | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column | sed -E -e "s/.*/${difficultyColor}&${endColour}/"
  else
   echo -e "\n${redColour}[!] La dificultad proporcionada no existe${endColour}\n"
  fi
}

function getOSMachines(){
  os="$1"

  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'
  osColor=""

  os_results="$(cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
 

  if [ "$os_results" ]; then

    if [ "$os" == "Windows" ]; then
      osColor=$blueColour
    else
      osColor=$greenColour
    fi

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas correspondientes al sistema operativo${endColour} ${osColor}$os${endColour} ${grayColour}:${endColour}\n"

    cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column | sed -E -e "s/.*/${osColor}&${endColour}/"
    
  else
    echo -e "\n${redColour}[!] El sistema operativo proporcionado es incorrecto${endColour}"
  fi
}

function getOSDifficultyMachines(){
  os="$1"
  difficulty="$2"
  
  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'
  difficultyColor=""
  osColor=""

  os_difficulty_results="$(cat bundle.js | grep  "so: \"$os\"" -B 4 -A 1 | iconv -f utf-8 -t ascii//TRANSLIT | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"
 
  
  if [ "$os" == "Windows" ]; then
    osColor=$blueColour
  else
    osColor=$greenColour
  fi

  if [ "$difficulty" == "Insane" ]; then
    difficultyColor=$redColour
  elif [ "$difficulty" == "Media" ]; then
    difficultyColor=$purpleColour
  elif [ "$difficulty" == "Dificil" ]; then
    difficultyColor=$yellowColour
  else
    difficultyColor=$turquoiseColour
  fi


  if [ "$os_difficulty_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las maquinas correspondientes al sistema operativo${endColour} ${osColor}$os${endColour} ${grayColour}y dificultad${endColour} ${difficultyColor}$difficulty${endColour}${grayColour}:${endColour}\n"

  cat bundle.js | grep  "so: \"$os\"" -B 4 -A 1 | iconv -f utf-8 -t ascii//TRANSLIT | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column | sed -E -e "s/.*/${difficultyColor}&${endColour}/"
  else
    echo -e "\n${redColour}[!] El sistema operativo o dificultad proporcionados son incorrectos${endColour}\n"
  fi
}

function searchMachinesBySkill(){
  skill="$1"
  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'

  skill_results="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"


  if [ "$skill_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las maquinas con Skill${endColour} ${purpleColour}$skill${endColour}${grayColour}:${endColour}\n"

cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "so: \"Windows\"" -B 5 |grep "name: "| awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column | sed -E -e "s/.*/${blueColour}&${endColour}/"

cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "so: \"Linux\"" -B 5 |grep "name: "| awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column | sed -E -e "s/.*/${greenColour}&${endColour}/"
  else
    echo -e "\n${redColour}[!] La Skill indicada no existe${endColour}\n"
  fi
}
function searchBySkillOSDifficulty(){
  skill="$1"

  os="$2"

  difficulty="$3"

  greenColour=$'\e[0;32m\033[1m'
  redColour=$'\e[0;31m\033[1m'
  yellowColour=$'\e[0;33m\033[1m'
  turquoiseColour=$'\e[0;36m\033[1m'
  grayColour=$'\e[0;37m\033[1m'
  purpleColour=$'\e[0;35m\033[1m'
  endColour=$'\033[0m\e[0m'
  blueColour=$'\e[0;34m\033[1m'
  osColor=""
  difficultyColor=""

  skill_os_difficulty_results="$(cat bundle.js | grep "skills: " -B 6 | iconv -f utf-8 -t ascii//TRANSLIT | grep "$skill" -i -B 6 | grep "so: \"$os\"" -B5 -A1 | grep "dificultad: \"$difficulty\"" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$os" == "Windows" ];then 
    osColor=$blueColour
  else
    osColor=$greenColour
  fi

  if [ "$difficulty" == "Facil" ];then 
    difficultyColor=$turquoiseColour
  elif [ "$difficulty" == "Media" ]; then
    difficultyColor=$purpleColour
  elif [ "$difficulty" == "Dificil" ]; then
    difficultyColor=$yellowColour
  else
    difficultyColor=$redColour
  fi

  if [ "$skill_os_difficulty_results" ]; then

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las maquinas correspondientes a la Skill${endColour} ${purpleColour}$skill${endColour}${grayColour}, sistema operativo${endColour} ${osColor}$os${endColour}${grayColour} y dificultad${endColour} ${difficultyColor}$difficulty${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | grep "skills: " -B 6 | iconv -f utf-8 -t ascii//TRANSLIT | grep "$skill" -i -B 6 | grep "so: \"$os\"" -B5 -A1 | grep "dificultad: \"$difficulty\"" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column | sed -E -e "s/.*/${osColor}&${endColour}/"

  else

  echo -e "\n${redColour}[!] Skill, sistema operativo o dificultad incorrectos${endColour}\n"

  fi
}

# Indicators
declare -i parameter_counter=0
declare -i chivato_os=0
declare -i chivato_difficulty=0
declare -i chivato_skill=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
    s) skill=$OPTARG; chivato_skill=1; let parameter_counter+=7;;
    h) ;;
  esac
done


if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
   getYoutubeLink $machineName 
elif [ $parameter_counter -eq 5 ]; then
   getMachinesDifficulty $difficulty 
elif [ $parameter_counter -eq 6 ]; then
    getOSMachines $os 
elif [ $chivato_skill -eq 1 ] && [ $chivato_os -eq 1 ] && [ $chivato_difficulty -eq 1 ]; then
  searchBySkillOSDifficulty "$skill" $os $difficulty
elif [ $chivato_os -eq 1 ] && [ $chivato_difficulty -eq 1 ]; then
  getOSDifficultyMachines $os $difficulty
elif [ $parameter_counter -eq 7 ]; then
  searchMachinesBySkill "$skill"
else
  helpPanel
fi


