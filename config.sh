#!/usr/bin/env bash
if [ "${EUID}" -eq 0 ]; then
  userdel -r dstserver
  dpkg --add-architecture i386
  apt update -y
  apt upgrade -y
  apt install -y curl wget file tar bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc jq tmux netcat lib32gcc1 lib32stdc++6 libsdl2-2.0-0:i386 steamcmd libcurl4-gnutls-dev:i386
  apt autoremove -y
  apt autoclean -y
  # Create dstserver user, log in and maintain pwd
  adduser dstserver
  su dstserver  # -c "cd $(pwd); bash"
else
  DIR="$(dirname "$(realpath "$0")")"
  if [ "$(whoami)" == "dstserver" ] && [ -f "${DIR}/cluster_token.txt" ]; then
    # Download linuxgsm script in home folder of dstserver user
    cd ~ || exit
    wget -O linuxgsm.sh https://linuxgsm.sh
    chmod +x linuxgsm.sh

    # Create two server controllers
    ./linuxgsm.sh dstserver
    ./linuxgsm.sh dstserver

    # Installation variables of master and caves
    mkdir -p ~/lgsm/config-lgsm/dstserver/
    echo '# Installation Variables
sharding="true"
master="true"
shard="Master"
cluster="Cluster_1"
cave="false"' >> ~/lgsm/config-lgsm/dstserver/dstserver.cfg
     echo '# Installation Variables
sharding="true"
master="false"
shard="Caves"
cluster="Cluster_1"
cave="true"' >> ~/lgsm/config-lgsm/dstserver/dstserver-2.cfg

    # Set cluster token
    mkdir -p ~/.klei/DoNotStarveTogether/Cluster_1/
    cp "${DIR}/cluster_token.txt" ~/.klei/DoNotStarveTogether/Cluster_1/cluster_token.txt

    # Install servers
    ./dstserver install
    ./dstserver-2 install

    # Configure Master / Caves
    mkdir -p ~/.klei/DoNotStarveTogether/Cluster_1/Master/
    mkdir -p ~/.klei/DoNotStarveTogether/Cluster_1/Caves/

    echo '[NETWORK]
server_port = 11000

[SHARD]
is_master = true

[STEAM]
authentication_port = 8768
master_server_port = 27018

[ACCOUNT]
encode_user_path = true' > ~/.klei/DoNotStarveTogether/Cluster_1/Master/server.ini

    echo '[NETWORK]
server_port = 11001

[STEAM]
authentication_port = 8769
master_server_port = 27019

[SHARD]
bind_ip = 127.0.0.1
is_master = false

[ACCOUNT]
encode_user_path = true' > ~/.klei/DoNotStarveTogether/Cluster_1/Caves/server.ini

    # Set shard_enabled = true if set to false
    if grep "shard_enabled = false" ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini &>/dev/null; then
      sed "s/shard_enabled = false/shard_enabled = true/g" -i ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini
    fi

    # main shard set to forest and cave shard set to caves
    echo 'return {
  override_enabled = false,
}' > ~/.klei/DoNotStarveTogether/Cluster_1/Master/worldgenoverride.lua

    echo 'return {
  override_enabled = true,
  preset = "DST_CAVE",
}' > ~/.klei/DoNotStarveTogether/Cluster_1/Caves/worldgenoverride.lua

    # Get workshop ID of desired mods
    echo '--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mods Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mods Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	ServerModSetup("810443397") -- A Big Bag 大背包 1.5 (permet craftejar una mochila de 64 espais)
	ServerModSetup("1416161108") -- Camp Security (Protegeix el campament de que es cremi)
	ServerModSetup("817025783") -- Craftable Gears - Configurable! (permet craftejar gears al menu refine i escollir quins materials fan falta per a la recepta)
  ServerModSetup("367304592") -- Digable Reeds (permet transplantar les plantes del pantano de papiro)
	ServerModSetup("352499675") -- DST easy resurrection shelter (permet reviure a un foc o bé construir el resurrection shelter per a reviure)
	ServerModSetup("382177939") -- DST Storm Cellar (permet construir la estructura storm cellar que es com un chester gegant fireproof)
	ServerModSetup("1242093526") -- Eternal glowcaps and mushlights
	-- ServerModSetup("1818688368") -- Extra Equip Slots (Updated) (afegeix un slot mes de equipo de motxilla i de amuleto)
	ServerModSetup("378160973") -- Global Positions (comparteix el mapa entre els jugadors i mostra la seva posicio a temps real al mapa)
	ServerModSetup("585654889") -- Glowing Portal (Fa que el portal de resurrect brilli, util per quan suneix gent i es de nit, sino moren al instant)
	ServerModSetup("374550642") -- Increased Stack size (permet stackejar els materials fins a 99)
	-- ServerModSetup("356930882") -- Infinite Tent uses (fa que les tendes per dormir no es desgastin)
	ServerModSetup("1839858501") -- Large Boats (permet construir vaixells molt mes grans)
	-- ServerModSetup("380423963") -- Mineable Gems (afegeix drop de una gema al petar una roca)
	ServerModSetup("2353205177") -- Moving Box (Updated) (permet empaquetar estructures per a moureles)
	ServerModSetup("466732225") -- No thermal stone durability (fa que les pedres termiques no sespatllin)
	ServerModSetup("471111069") -- Only fertilize once (fertilitza les plantes nomes un cop)
	ServerModSetup("856487758") -- Quick drop (permet llençar les coses al lloc en el que estás sense haver de arrastrar a fora de linventari)
	ServerModSetup("501385076") -- Quick Pick (permet agafar les coses de forma mes rapida)
	ServerModSetup("666155465") -- Show me (Origin) (Mostra contenidors amb el mateixos objectes que portes a la ma, dona info de temps de recreixement de plantes i crops, dona info de les eines i del menjar, mostra la vida dels bitxos... amb aquest deixa de fer falta health info, display food values i finder)
	ServerModSetup("1207269058") -- Simple Health Bar DST (mostra la barra de vida i mostra el dany / heal, es pot configurar per a veure lo dels corets. Deixa de fer falta health info)
	ServerModSetup("599498678") -- Tools are fuels (permet llençar tools al foc, útil per eines amb percentatge low)

	-- Discarded
	-- ServerModSetup("382501575") -- Crash Bandicoot (Afegeix fruta woompa pel mapa i la possibilitat descollir a crash com a personatge. crash r¡cupera sanity de forma pasiva i porta sempre a aku-aku de acompanyant, pero aquest te una sanity aura de -100 :/ )
	-- ServerModSetup("2340409563") -- Let me sprint! (Permet sprintar mantent polsat shift amb cost de gana)
	-- ServerModSetup("463740026") -- Personal chesters (afegeix un chester a cada jugador)
	-- ServerModSetup("347360448") -- DST Where is my beefalo (mostra la localització del beefalo y altres mobs, incloent bosses)
	-- ServerModSetup("350811795") -- Soul mates (allows crafting of the teleport rings, which allows to teleport from one character to another)


--ServerModCollectionSetup takes a string of a specific mods Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collections Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
    ' > ~/serverfiles/mods/dedicated_server_mods_setup.lua

    # Mod overrides (config of mods)
    modoverrides='
    return {
  ["workshop-2353205177"]={
    configuration_options={
      arrowsign_post=true,
      beebox=true,
      beefalo_groomer=true,
      birdcage=true,
      cartographydesk=true,
      compostingbin=true,
      cookpot=true,
      dragonflychest=true,
      dragonflyfurnace=true,
      endtable=true,
      eyeturret=true,
      fence=true,
      fence_gate=true,
      firesuppressor=true,
      fish_box=true,
      homesign=true,
      icebox=true,
      lightning_rod=true,
      madscience_lab=true,
      mast=true,
      mast_malbatross=true,
      meatrack=true,
      minisign=true,
      modsupport=false,
      moondial=true,
      mushroom_farm=true,
      mushroom_light=true,
      mushroom_light2=true,
      nightlight=true,
      perdshrine=true,
      pigshrine=true,
      pottedfern=true,
      rainometer=true,
      researchlab=true,
      researchlab2=true,
      researchlab3=true,
      researchlab4=true,
      resurrectionstatue=true,
      ruinsrelic_bowl=true,
      ruinsrelic_chair=true,
      ruinsrelic_chipbowl=true,
      ruinsrelic_plate=true,
      ruinsrelic_table=true,
      ruinsrelic_vase=true,
      saltbox=true,
      saltlick=true,
      scarecrow=true,
      sculptingtable=true,
      seafaring_prototyper=true,
      sentryward=true,
      siestahut=true,
      steeringwheel=true,
      succulent_potted=true,
      table_winters_feast=true,
      tacklestation=true,
      townportal=true,
      treasurechest=true,
      trophyscale_fish=true,
      trophyscale_oversizedveggies=true,
      turfcraftingstation=true,
      wall_hay=true,
      wall_moonrock=true,
      wall_ruins=true,
      wall_stone=true,
      wall_wood=true,
      wardrobe=true,
      waterpump=true,
      winona_battery_high=true,
      winona_battery_low=true,
      winona_catapult=true,
      winona_spotlight=true,
      winter_treestand=true,
      winterometer=true,
      wintersfeastoven=true,
      yotb_beefaloshrine=true,
      yotb_post=true,
      yotb_sewingmachine=true,
      yotb_stage=true
    },
    enabled=true
  },
  ["workshop-1207269058"]={ configuration_options={  }, enabled=true },
  ["workshop-1242093526"]={ configuration_options={ glowcap=1, mushlight=1, winter_tree=0 }, enabled=true },
  ["workshop-1416161108"]={
    configuration_options={
      [""]=0,
      auto_add_to_list=false,
      auto_add_to_list_drop=false,
      auto_del_from_list=false,
      auto_del_from_list_drop=false,
      ban_time=1800,
      beebox_radius=false,
      builder_radius=false,
      building_burned_down=false,
      campfire_propagator=false,
      chester_protect=false,
      death_annonce=false,
      destruction_protection=false,
      destruction_punishment=false,
      destruction_vote=false,
      destruction_warning=false,
      dont_drop_when_died=false,
      egg_deploy=false,
      fire_protection=false,
      fire_punishment=false,
      fire_radius=false,
      fire_vote=false,
      fire_warning=false,
      firehound_propagator=false,
      flingomatic_improved=false,
      flingomatic_is_empty=false,
      glommer_protect=false,
      good_monsters=false,
      keybind_container=114,
      keybind_drop=106,
      keybind_friend=107,
      keybind_panel=108,
      language="En",
      lavae_protect=false,
      mob_broke=false,
      protect_wall=false,
      punishmentTip=false,
      read_radius=false,
      reeds_cactus=false,
      starcaller=false,
      test=false,
      vote_kick_time=3600,
      warnings_count=5
    },
    enabled=true
  },
  ["workshop-1818688368"]={ configuration_options={  }, enabled=true },
  ["workshop-1839858501"]={ configuration_options={  }, enabled=true },
  ["workshop-352499675"]={
    configuration_options={ [""]=0, Mode="hard", ShelterLight="yes", ShelterUses=1000000 },
    enabled=true
  },
  ["workshop-356930882"]={
    configuration_options={ uses=10000000, uses2=10000000, uses3=10000000 },
    enabled=true
  },
  ["workshop-367304592"]={ configuration_options={  }, enabled=true },
  ["workshop-374550642"]={ configuration_options={ MAXSTACKSIZE=99 }, enabled=true },
  ["workshop-378160973"]={
    configuration_options={
      ENABLEPINGS=true,
      FIREOPTIONS=2,
      OVERRIDEMODE=false,
      SHAREMINIMAPPROGRESS=true,
      SHOWFIREICONS=true,
      SHOWPLAYERICONS=true,
      SHOWPLAYERSOPTIONS=2
    },
    enabled=true
  },
  ["workshop-380423963"]={
    configuration_options={
      [""]=0,
      boulder_blue=0.05,
      boulder_purple=0.05,
      change_cave_loot=false,
      common_loot_charcoal=0,
      common_loot_flint=0.35,
      common_loot_rocks=0.35,
      cutlichen=0,
      durian=0,
      flintless_blue=0.05,
      flintless_purple=0.05,
      flintless_red=0.05,
      foliage=0,
      gears=0,
      goldvein_purple=0.05,
      goldvein_red=0.05,
      guano=0,
      ice=0,
      lightbulb=0,
      moon_green=0.05,
      moon_orange=0.05,
      moon_yellow=0.05,
      pinecone=0,
      rare_loot_bluegem=0.05,
      rare_loot_marble=0.05,
      rare_loot_redgem=0.05,
      rottenegg=0,
      seeds=0,
      spoiled_food=0,
      stalagmite_green=0.05,
      stalagmite_orange=0.05,
      stalagmite_yellow=0.05,
      uncommon_loot_goldnugget=0.05,
      uncommon_loot_mole=0.05,
      uncommon_loot_nitre=0.05,
      uncommon_loot_rabbit=0.05
    },
    enabled=true
  },
  ["workshop-382177939"]={
    configuration_options={ [""]=true, chillit="yep", eightxten="8x10", workit="yep" },
    enabled=true
  },
  ["workshop-463740026"]={ configuration_options={ ownership=false }, enabled=true },
  ["workshop-466732225"]={ configuration_options={  }, enabled=true },
  ["workshop-471111069"]={ configuration_options={  }, enabled=true },
  ["workshop-501385076"]={
    configuration_options={
      quick_cook_on_fire=true,
      quick_harvest=true,
      quick_pick_cactus=true,
      quick_pick_plant_normal_ground=true
    },
    enabled=true
  },
  ["workshop-585654889"]={ configuration_options={  }, enabled=true },
  ["workshop-599498678"]={ configuration_options={  }, enabled=true },
  ["workshop-666155465"]={
    configuration_options={
      chestB=-1,
      chestG=-1,
      chestR=-1,
      display_hp=-1,
      food_estimation=-1,
      food_order=0,
      food_style=0,
      lang="auto",
      show_food_units=-1,
      show_uses=-1
    },
    enabled=true
  },
  ["workshop-810443397"]={
    configuration_options={
      FRESH=false,
      GIVE=false,
      LANG=0,
      LIGHT=true,
      RECIPE=5,
      STACK=false,
      WALKSPEED=1.5
    },
    enabled=true
  },
  ["workshop-817025783"]={
    configuration_options={
      [""]=0,
      Amount1=1,
      Amount2=1,
      Amount3=3,
      Amount4=1,
      AmountCrafted=1,
      Component1="cutstone",
      Component2="transistor",
      Component3="goldnugget",
      Component4=0,
      CraftStation=2,
      CraftTab=2
    },
    enabled=true
  },
  ["workshop-856487758"]={ configuration_options={  }, enabled=true }
}'
    echo "${modoverrides}" > ~/.klei/DoNotStarveTogether/Cluster_1/Caves/modoverrides.lua
    echo "${modoverrides}" > ~/.klei/DoNotStarveTogether/Cluster_1/Master/modoverrides.lua

    # Change game mode from cluster.ini
    if grep "game_mode = survival" ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini &>/dev/null; then
      sed "s/game_mode = survival/game_mode = endless/g" -i ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini
    fi

    # Change description from cluster.ini
    if grep "cluster_description = This server was created by LGSM!" ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini &>/dev/null; then
      sed "s/cluster_description = This server was created by LGSM!/cluster_description = footClapFOOTClap/g" -i ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini
    fi

    # Change name from cluster.ini
    if grep "cluster_name = LinuxGSM" ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini &>/dev/null; then
      sed "s/cluster_name = LinuxGSM/cluster_name = peuClapPEUClap/g" -i ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini
    fi

    # Change password from cluster.ini
    if grep "cluster_password =" ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini &>/dev/null; then
      sed "s/cluster_password =/cluster_password = SSAP/g" -i ~/.klei/DoNotStarveTogether/Cluster_1/cluster.ini
    fi


    # World generation overrides
    echo '
return {
  override_enabled=true,
  overrides={

  }
}
    ' > ~/.klei/DoNotStarveTogether/Cluster_1/Master/worldgenoverride.lua
    # World generation overrides (caves)
    echo '
return {
  preset="DST_CAVES",
  override_enabled=true,
  overrides={
    world_size="huge",
    boons="mostly",
    start_location="plus",
  }
}
    ' > ~/.klei/DoNotStarveTogether/Cluster_1/Caves/worldgenoverride.lua

    # Load crontab to autoexecute servers on boot
    echo '@reboot /home/dstserver/dstserver start 2>&1 | tee /home/dstserver/dstserver.log
@reboot /home/dstserver/dstserver-2 start 2>&1 | tee /home/dstserver/dstserver-2.log' > crontab_file
    crontab crontab_file

    # start servers
    # ./dstserver start
    # ./dstserver-2 start
  else
    echo "You have to be dstserver user and have the cluster token on the directory where rhe config-sh script is located"
    exit
  fi
fi
