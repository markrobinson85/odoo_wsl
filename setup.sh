#!/bin/bash

clear

echo "==================================================================================================="
echo "---------------------------------------------------------------------------------------------------"
echo "                                                                                                   "
echo "                                             dd                                                    "
echo "                                            dddd                                                   "
echo "                                            dddd                                                   "
echo "             OOOOOOOOOOO         ddddddddddddddd     OOOOOOOOOOO         OOOOOOOOOOO               "
echo "          OOOOO      OOOOO    ddddddd   dddddddd  OOOOOOO   OOOOOOO    OOOOOOO  OOOOOOO            "
echo "         OOOO          OOOO  ddddd         ddddd OOOOO         OOOOO  OOOO          OOOO           "
echo "        OOOOO           OOOO dddd           dddd OOOO           OOOO OOOO           OOOO           "
echo "         OOOO          OOOOO dddd           dddd OOOO           OOOO OOOOO          OOOO           "
echo "          OOOOO      OOOOOO   ddddd       ddddd   OOOOO       OOOOO   OOOOOO      OOOOO            "
echo "            OOOOOOOOOOOOO       ddddddddddddd       OOOOOOOOOOOOO       OOOOOOOOOOOOO              "
echo "                                                                                                   "
echo "                        Odoo Development Environment Setup for Pycharm                             "
echo "---------------------------------------------------------------------------------------------------"
echo "----===================================================================----------------------------"
echo "----=                                                                 =----------------------------"
echo "----= Welcome. This script will setup your Python dependancies and    =----------------------------"
echo "----= virtual environments. This script will store or use projects    =----------------------------"
echo "----= located in your ~/PycharmProjects directory. You can rerun      =----------------------------"
echo "----= this script later to setup your venvs.                          =----------------------------"
echo "----=                                                                 =----------------------------"
echo "----===================================================================----------------------------"
echo "---------------------------------------------------------------------------------------------------"
# echo "----= Affirmative answers should be y. Empty answers are considered negative. =--------------------"
echo "---------------------------------------------------------------------------------------------------"
if [[ "$WSL_DISTRO_NAME" ]] && [[ $(uname -r | grep -n 'WSL2') ]]; then
    install_wsl="y"
    win_hostname="$(powershell.exe '[Console]::Write($env:COMPUTERNAME)').local"
    echo "---------------------------------------------------------------------------------------------------"
    echo "----= $WSL_DISTRO_NAME on WSL2 was detected...                                  =----------------------------"
    echo "---------------------------------------------------------------------------------------------------"
elif [[ "$WSL_DISTRO_NAME" ]];
then
    echo "WSL1 is not supported. Please upgrade to WSL2."
    exit 0
fi

read -p "Do you wish to setup new or existing projects? [y/n] " install_project
read -p "Show advanced or first time setup options? [y/n] " install_advanced

if [[ $install_advanced == "y" ]]
then
    read -p "Install Python and Nginx onto your system? [y/n] " install_dep
    read -p "Install Postgres v12 onto your system? [y/n] " install_postgres
fi

install_systemd=no
install_git_cred=no

if [[ $install_wsl == "y" ]] && [[ $install_advanced == "y" ]];
then
   
    # Check git is installed on Windows.
    if ! $(git.exe --version);
    then
        echo "Error: Git is not installed on Windows. Please install Git to continue. "
        echo "In a Windows 11 PowerShell, you can run:"
        echo "winget install git.git"
        echo ""
        echo "If you recently installed git on Windows, you may need to restart your terminal or PC."
        exit 0
    fi
    # if [[ $install_git_lf == "y" ]];
    # then
        echo "Force LF line endings in git."
        git config --global core.eol lf
        echo ""
        echo "Done!"
        echo ""
    # fi
    # Check if git credential manager is configured for WSL.
    ask_git_cred="no"
    echo "WSL Configuration"
    if [[ -f "/mnt/c/Program Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe" && ! $(git config --global credential.helper) =~ Git/mingw64/libexec/git-core/git-credential-manager-core.exe ]] || [[ -f "/mnt/c/Program Files/Git/mingw64/libexec/git-core/git-credential-manager.exe" && ! $(git config --global credential.helper) =~ Git/mingw64/libexec/git-core/git-credential-manager.exe ]];
    then
        echo "Do you want to configure WSL with git Credential Helper on Windows?"
        echo "Setting up git Credential Helper will enable app authentication in Windows for "
        echo "Github, Bitbucket, etc."
        echo "Make sure git is up-to-date on your Windows machine..."
        echo ""
        read -p "Enable git Credential Manager? (recommended) [y/n] " install_git_cred
    fi

    # read -p "Do you wish to install systemd on WSL? (experimental) [y/n] " install_systemd
    read -p "Reset PyCharm firewall rules? [y/n] " install_reset_pycharm
    
    # if [[ ! $(git config --global core.eol) == lf ]];
    # then
    #     read -p "Force LF line endings with git? (experimental) [y/n] " install_git_lf
    # fi
fi

echo ""
echo ""
echo "Let's begin!"
echo ""
echo ""

if [[ $install_git_cred == "y" ]];
then
    echo "Setup git credential helper..."
    echo "This will enable git on WSL to access the git credential manager on Windows."
    read -p "Press ENTER to continue, or CTRL + C to cancel..."
    # Some versions
    if [[ -f '/mnt/c/Program Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe' ]];
    then
        git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"
    elif [[ -f '/mnt/c/Program Files/Git/mingw64/libexec/git-core/git-credential-manager.exe' ]];
    then
        git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
    else
        echo "Git credential manager on Windows not found."
        exit 0
    fi
    echo ""
    echo "Done!"
    echo ""
fi


if [[ $install_systemd == "y" ]];
then
    read -p "Press ENTER to continue with installing systemd on WSL.."
    echo "Downloading script to enable systemd on WSL..."
    git clone https://github.com/vendvahk/ubuntu-wsl2-systemd-script.git ./wsl2-systemd

    echo "Installing systemd on WSL..."
    cd 
    chmod +x ./wsl2-systemd/install.sh
    ./wsl2-systemd/install.sh
    cd ..
    echo ""
    echo "Done!"
    echo ""
    echo "Installation of systemd on WSL complete."
    
    echo "You may need to manually run the following two commands in Windows cmd.exe:"
    echo
    echo "  setx WSLENV BASH_ENV/u"
    echo "  setx BASH_ENV /etc/bash.bashrc"
    echo
    read -p "Press ENTER to continue..."
fi

if [[ $install_reset_pycharm == "y" ]]
then
    echo "An elevated command will run to reset PyCharm firewall rules."
    echo ""
    echo "==================================================================================================="
    sleep 10s
    powershell.exe -Command "Start-Process PowerShell -Verb RunAs \"-NoProfile -ExecutionPolicy Bypass -Command \`\"Get-NetFirewallRule | where DisplayName -ILike 'PyCharm*' | Remove-NetFirewallRule\`\" \";"
    echo ""
    echo "Done!"
    echo ""
fi

if [[ $install_dep == "y" ]];
then
    . /etc/lsb-release

    read -p "Press ENTER to continue with installing Python and dependancies.."
#     echo "Enabling higher fsnotify for IDE."
#     sudo bash -c 'cat >> /etc/sysctl.d/idea.conf <<EOL
# fs.inotify.max_user_watches = 524288
# EOL'
    if [[ ! -f /etc/apt/sources.list.d/pgdg.list ]]
    then
        sudo wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - 
        echo "Setup Postgres repo..."
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
    fi

    if [[ $? -ne 0 ]]; then
        echo "Failed to set system inotify variable..."
        exit 1
    fi

    echo "Running OS upgrades..."
    sudo apt update
    if [[ $? -ne 0 ]]; then
        echo "Failed to update..."
        exit 1
    fi
    sudo apt upgrade
    if [[ $? -ne 0 ]]; then
        echo "Failed to upgrade..."
        exit 1
    fi
    echo "Installing nginx..."
    sudo apt install -y nginx
    
    sudo service nginx restart

    if [[ $install_wsl == "y" ]] && [[ ! -f /etc/wsl.conf ]];
    then
        # If WSL and no wsl.conf exists, create one to start nginx service on boot.
        sudo bash -c 'cat >> /etc/wsl.conf <<EOL
[boot]
command="service nginx restart;"
EOL'
    fi

    echo "Adding apt repository for python version..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    if [[ $? -ne 0 ]]; then
        echo "Failed to add apt-repository for python..."
        exit 1
    fi

    echo "Installing python 3.8..."
    sudo apt-get -y install python3.8 python3.8-dev python3.8-venv build-essential
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Python 3.8..."
        exit 1
    fi
    
    echo "Installing python 3.7..."
    sudo apt install -y python3.7-dev python3.7-venv build-essential python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libpq-dev python3-pip software-properties-common
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Python 3.7..."
        exit 1
    fi

    pip3 install wheel matplotlib
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Python 3.8..."
        exit 1
    fi

    echo "Installing wkhtmltopdf 0.12.6..."
    # if [[ $DISTRIB_RELEASE == '20.04' ]]
    # then
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.$(lsb_release -cs)_amd64.deb
    sudo apt install -y ./wkhtmltox_0.12.6-1.$(lsb_release -cs)_amd64.deb
    if [[ $? -ne 0 ]]; then
        read -p "Unable to install wkhtmltopdf. Please do this manually."
        
    fi 
    # elif [[ $DISTRIB_RELEASE == '18.04' ]]
    # then
    #     wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb
    #     sudo apt install -y ./wkhtmltox_0.12.6-1.bionic_amd64.deb
    # else
    #     echo "Unable to install wkhtmltopdf. Please do this manually."
    # fi

    read -p "Do you need Python 2.7? (optional) [y/n] " install_py27
    if [[ $install_py27 == "y" ]]
    then
        echo "Installing python 2.7..."
        sudo apt install -y python2 python2-dev npm

        echo "Downloading installation script for PIP for Python 2..."

        curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py

        echo "Installing PIP for Python 2..."
        sudo python2 get-pip.py
        
        sudo npm install -g less
    fi
    
    sudo apt install -y virtualenv python3-pypdf2 postgresql-client-12
    
    echo ""
    echo "Done!"
    echo ""
    echo "Finished installing Python and build dependencies..."
    read -p "Press ENTER to continue..."
fi

if [[ $install_postgres == "y" ]]
then
echo "Installing Postgres 12..."

echo "Installing..."
sudo apt -y install postgresql-12

echo ""
echo "Done!"
echo ""
fi

echo "Setup projects"
# Setup projects
if [[ $install_project == "y" ]];
then
    work=1
    clear
    echo "---------------------------------------------------------------------------------------------------"
    echo "==================================================================================================="
    echo "---------------------------------------------------------------------------------------------------"
    echo " This script assumes you use this example directory structure when  "
    echo " setting up your venvs for each project."
    echo " "
    echo " Example Project Directory Structure "
    echo " ~/PycharmProjects "
    echo " |- Odoo13-ClientOne      # Main Project Directory" 
    echo "   |- clientone-addons       # Client Addons Directory"
    echo "   |- configs             # conf files"
    echo "   |- venv                # Client Project venv"
    echo " |- Odoo14-ClientTwo "
    echo "   |- clienttwo-addons "
    echo "   |- configs"
    echo "   |- venv"
    # echo " |- Odoo15-ClientThree "
    # echo "   |- clientthree-addons "
    # echo "   |- configs"
    # echo "   |- venv"
    echo " |- shared                # Shared repositories between client projects"
    echo "   |- v13.0               # Version 13.0 related repos"
    echo "     |- odoo              # Version 13 of odoo repo"
    echo "     |- enterprise        # Version 13 of enterprise repo"
    echo "     |- odoo-stubs        # Version 13 of odoo stubs for Odoo Pycharm Plugin"
    echo "     |- oca               # Version 13 version of various OCA repos"
    echo "   |- v14.0"
    echo "     |- odoo"     
    echo "     |- enterprise"
    echo "     |- oca"
    echo "---------------------------------------------------------------------------------------------------"
    echo "==================================================================================================="
    # read -p "Press ENTER to continue..."
    # echo " "
    # echo " To attach shared resources in Pycharm:" 
    # echo " 1. Click File > Settings > Project > Project Structure. "
    # echo " 2. Click + Add Content Root. "
    # echo " 3. Add shared/v##/odoo "
    # echo " 4. Add shared/v##/enterprise "
    # echo " 5. Add shared/v##/odoo-stubs "
    # echo " "
    # echo "---------------------------------------------------------------------------------------------------"
    # echo "==================================================================================================="
    # read -p "Press ENTER to continue..."

    while [ $work == 1 ]
    do
        project_dir=""
        default_admin_pass="Development"
        echo "================= You must store your projects in the ~/PycharmProjects directory ================="
        echo "---------------------------------------------------------------------------------------------------"
        read -p "Enter the client name with camel case (no spaces): (ie. ClientName or CN) " project_client
        read -p "Enter a lowercase shortname for the client. (ie. client) " project_shortname
        read -p "Enter the Odoo version number, including decimal: (ie 13.0) " project_version
        
                # Create project directory structure.
        if [[ ! -d ~/PycharmProjects ]]
        then
            mkdir ~/PycharmProjects
        fi
        if [[ ! -d ~/PycharmProjects/shared ]]
        then
            mkdir ~/PycharmProjects/shared
        fi
        if [[ ! -d ~/PycharmProjects/shared/v$project_version ]]
        then
            mkdir ~/PycharmProjects/shared/v$project_version
        fi

        if [[ ! "$project_version" =~ ^[0-9]+(\.[0-9]+)$ ]]
        then
            echo "Must be a valid Odoo version number. Exiting..."
            exit 0
        fi
        
        version=$((${project_version%.*}))
        project_dir="Odoo$version-$project_client"
        project_addons="$project_shortname-addons"

        echo "Project files will be located in ~/PycharmProjects/$project_dir/$project_addons"
        if [[ ! -d ~/PycharmProjects/$project_dir ]]
        then
            mkdir ~/PycharmProjects/$project_dir
            create_new_project="y"
            read -p "Provide git repository URL to clone addons: (Optional) " project_git_url
            read -p "Branch: " project_branch
            if [[ $project_git_url ]]
            then
                git ls-remote $project_git_url --quiet
            fi
        fi

        if [[ $create_new_project ]];
        then
            read -p "Set password for Odoo Database Manager (web/database/manager): [default: Development] " project_admin_password && [[ -z "$project_admin_password" ]] && project_admin_password="$default_admin_pass"
            read -p "Use custom XMLRPC and longpolling ports for this project? [y/n] " project_custom_ports
            project_xmlrpc="8069"
            project_longpolling="8072"
            if [[ $project_custom_ports == "y" ]]
            then
                read -p "XMLRPC Port: " project_xmlrpc
                read -p "Longpolling Port: " project_longpolling
            fi

            echo "================= Database Settings ==============================================================="
            echo "Where will the database for this project be hosted? "
            echo "      1. This machine (localhost) "
            echo "      2. Another machine or virtual machine on my network "
            echo "      3. Configure manually later "
            if [[ $install_wsl == "y" ]]
            then
                echo "      4. This machine (on Windows) "
            fi
            default_postgres_option="1"
            read -p "Enter the option number: [default: 1] " postgres_option && [[ -z "$postgres_option" ]] && postgres_option="$default_postgres_option"

            if [[ $postgres_option != "3" ]]
            then
                if [[ $postgres_option == '2' ]]
                then
                    read -p "Database hostname: " postgres_hostname
                elif [[ $postgres_option == '1' ]]
                then
                    postgres_hostname="localhost"
                elif [[ $postgres_option == "4" ]]
                then
                    postgres_hostname=$win_hostname
                fi
                default_postgres_port="5432"
                read -p "Database port [default: 5432]: " postgres_port && [[ -z "$postgres_port" ]] && postgres_port="$default_postgres_port"
                read -p "Database user: " postgres_username
                read -s -p "Database password: " postgres_password
                echo ""
            fi
        fi

        if [[ $project_shortname == "" ]] || [[ $project_dir == "" ]] || [[ $project_addons == "" ]] || [[ $project_version == "" ]]
        then
            echo "Some project fields were not entered. Exiting..."
            exit 0
        fi

        if [[ ! -d ~/PycharmProjects/shared/v$project_version/odoo ]]
        then
        
            echo "Odoo resources for this version are missing."
            echo "Fetching shared Odoo resources for $project_version..."
            echo "Cloning into ~/PycharmProjects/shared/v$project_version/odoo"
            git ls-remote https://github.com/odoo/odoo.git --quiet
            git ls-remote https://github.com/odoo-ide/odoo-stubs.git --quiet

            git ls-remote git@github.com:odoo/enterprise.git --quiet
            if [[ $? -ne 0 ]]; then
                echo "Failed to authenticate with Github..."
                if [[ $install_wsl ]]
                then
                    echo "Please try deleting your github credentials from the Windows Credential Manager."
                    echo "Press Start > type 'Credential Manager' > Under Windows Credentials, locate and "
                    echo "delete credentials which may be conflicting."
                fi
                read -p "Press ENTER to try again."
                git ls-remote git@github.com:odoo/enterprise.git --quiet
                if [[ $? -ne 0 ]]; then
                    read -p "Still failed to authenticate with github."
                fi
                exit 1
            fi

            git clone --quiet https://github.com/odoo/odoo.git --depth 1 -b $project_version ~/PycharmProjects/shared/v$project_version/odoo &
            P1=$!
            echo "Cloning into ~/PycharmProjects/shared/v$project_version/enterprise"
            git clone --quiet git@github.com:odoo/enterprise.git --depth 1 -b $project_version ~/PycharmProjects/shared/v$project_version/enterprise &
            P2=$!
            if [[ $project_version != "9.0" ]] && [[ $project_version != "10.0" ]]
            then
                echo "Cloning into ~/PycharmProjects/shared/v$project_version/odoo-stubs"
                git clone --quiet https://github.com/odoo-ide/odoo-stubs.git --depth 1 -b $project_version ~/PycharmProjects/shared/v$project_version/odoo-stubs &
                P3=$!
            fi
        fi
        if [[ ! $create_new_project ]]
        then
            wait $P1 $P2 $P3
        fi
        if [[ $create_new_project ]]
        then            
            
            if [[ $project_git_url != "" ]]
            then
                # echo "Cloning $project_git_url into ~/PycharmProjects/$project_dir/$project_addons ..."
                if [[ $project_branch ]]
                then
                    git clone $project_git_url ~/PycharmProjects/$project_dir/$project_addons -b $project_branch &
                    P4=$!
                else
                    git clone $project_git_url ~/PycharmProjects/$project_dir/$project_addons &
                    P4=$!
                fi
                
                wait $P1 $P2 $P3 $P4

                echo ""
                echo "Done! Odoo resources for $project_version downloaded."
                echo ""
                
            elif [[ $project_addons != "" ]]
            then
                mkdir ~/PycharmProjects/$project_dir/$project_addons
            fi
            
            wait
            
            mkdir ~/PycharmProjects/$project_dir/configs
            mkdir ~/PycharmProjects/$project_dir/.idea
            project_path="$HOME/PycharmProjects/$project_dir"

            echo "Creating .conf file at ~/PycharmProjects/$project_dir/configs/test-server.conf"
            cat >> ~/PycharmProjects/$project_dir/configs/test-server.conf <<EOL
[options]
addons_path = ../shared/v$project_version/enterprise,../shared/v$project_version/odoo/addons,$project_addons
admin_passwd = $project_admin_password
db_host = $postgres_hostname
db_maxconn = 64
db_password = $postgres_password
db_port = $postgres_port
db_template = template1
db_user = $postgres_username
server_wide_modules=web
demo=True
EOL
            echo "Creating .conf file at ~/PycharmProjects/$project_dir/configs/odoo-server.conf"
            cat >> ~/PycharmProjects/$project_dir/configs/odoo-server.conf <<EOL
[options]
addons_path = ../shared/v$project_version/enterprise,../shared/v$project_version/odoo/addons,$project_addons
admin_passwd = $project_admin_password
db_host = $postgres_hostname
db_maxconn = 64
db_password = $postgres_password
db_port = $postgres_port
db_template = template1
db_user = $postgres_username
server_wide_modules=web
xmlrpc_port = $project_xmlrpc
log_level = info
limit_time_cpu = 999999
limit_time_real = 999999
EOL
            echo "Creating .conf file at ~/PycharmProjects/$project_dir/configs/odoo-server-workers.conf"
            cat >> ~/PycharmProjects/$project_dir/configs/odoo-server-workers.conf <<EOL
[options]
addons_path = ../shared/v$project_version/enterprise,../shared/v$project_version/odoo/addons,$project_addons
admin_passwd = $project_admin_password
db_host = $postgres_hostname
db_maxconn = 64
db_password = $postgres_password
db_port = $postgres_port
db_template = template1
db_user = $postgres_username
server_wide_modules=web
xmlrpc_port = $project_xmlrpc
longpolling_port = $project_longpolling
proxy_mode = True
log_level = info
workers = 2
max_cron_threads = 2

#-----------------------------------------------------------------------------
# Prevents the worker from using more than <limit> CPU seconds for each
# request. If the limit is exceeded, the worker is killed
#-----------------------------------------------------------------------------
limit_time_cpu = 108000

#-----------------------------------------------------------------------------
# Prevents the worker from taking longer than <limit> seconds to process a
# request. If the limit is exceeded, the worker is killed.
#-----------------------------------------------------------------------------
limit_time_real = 108000

#-----------------------------------------------------------------------------
# Maximum allowed virtual memory per worker. If the limit is exceeded, the
# worker is killed and recycled at the end of the current request.
#-----------------------------------------------------------------------------
limit_memory_soft = 1244918057

#-----------------------------------------------------------------------------
# Hard limit on virtual memory, any worker exceeding the limit will be
# immediately killed without waiting for the end of the current request
# processing.
#-----------------------------------------------------------------------------
limit_memory_hard = 6684354560

#-----------------------------------------------------------------------------
# Number of requests a worker will process before being recycled and restarted.
#-----------------------------------------------------------------------------
limit_request = 8196

EOL
            echo "Creating nginx site .conf file at ~/PycharmProjects/$project_dir/configs/nginx.conf"
            cat >> ~/PycharmProjects/$project_dir/configs/nginx.conf <<EOL
proxy_cache_path /var/lib/nginx/cache/$project_shortname levels=1:2 keys_zone=${project_shortname}_backcache:10m max_size=2g inactive=120m use_temp_path=off;
upstream odoo-$project_shortname-backend {
    server localhost:$project_xmlrpc weight=1 fail_timeout=0;
    keepalive 32;
}
upstream odoo-$project_shortname-im {
    server localhost:$project_longpolling;
}
server {
    listen        80;
    server_name   $project_shortname.odoo.test;
    # Specifies the maximum accepted body size of a client request,
    # as indicated by the request header Content-Length.
    client_max_body_size 250m;
    # log files
    access_log    /var/log/nginx/odoo-$project_shortname-access.log;
    error_log    /var/log/nginx/odoo-$project_shortname-error.log;
    # increase proxy buffer to handle some OpenERP web requests
    proxy_buffers 8 8k;
    proxy_buffer_size 8k;
    location / {
        allow all;
        proxy_http_version 1.1;
        proxy_connect_timeout       10800;
        proxy_send_timeout          10800;
        send_timeout                10800;
        #proxy_read_timeout         10800;
        proxy_read_timeout          300000;
        proxy_set_header Connection "";
        proxy_pass  http://odoo-$project_shortname-backend;

        # Expand gateway timeout period to handle slow queries in Odoo
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_redirect    off;
    }
    location ~* /web/static/ {
        allow all;
        proxy_cache ${project_shortname}_backcache;
        proxy_ignore_headers Cache-Control Expires Set-Cookie;
        proxy_cache_background_update on;
        proxy_cache_revalidate on;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;

        proxy_hide_header Set-Cookie;

        proxy_buffering    on;

        add_header X-Proxy-Cache \$upstream_cache_status;

        proxy_cache_valid any 60m;
        proxy_cache_valid 404 1m;

        proxy_redirect    off;

        proxy_pass http://odoo-$project_shortname-backend;
    }
    location ~* /web/image/ {
        allow all;
        proxy_cache ${project_shortname}_backcache;
        proxy_ignore_headers Cache-Control Expires Set-Cookie;
        proxy_cache_background_update on;
        proxy_cache_revalidate on;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;

        proxy_hide_header Set-Cookie;

        proxy_buffering    on;

        add_header X-Proxy-Cache \$upstream_cache_status;

        proxy_cache_valid any 60m;
        proxy_cache_valid 404 1m;

        proxy_redirect    off;

        proxy_pass http://odoo-$project_shortname-backend;
    }
    location /longpolling {
        proxy_pass http://odoo-$project_shortname-im;
        proxy_connect_timeout       600;
        proxy_send_timeout          600;
        proxy_read_timeout          600;
        send_timeout                600;
        proxy_set_header Connection "";
    }
}
EOL
        wait

        if [[ $OSTYPE == 'darwin'* ]];
        then 
            if [[ ! -d /usr/local/var/log/nginx/cache ]]
            then
                sudo mkdir /usr/local/var/log/nginx/cache
            fi
            if [[ ! -d /usr/local/var/log/nginx/cache/$project_shortname ]]
            then
                sudo mkdir /usr/local/var/log/nginx/cache/$project_shortname
            fi
        else
            if [[ ! -d /var/lib/nginx/cache ]]
            then
                sudo mkdir /var/lib/nginx/cache
            fi
            if [[ ! -d /var/lib/nginx/cache/$project_shortname ]]
            then
                sudo mkdir /var/lib/nginx/cache/$project_shortname
            fi
        fi
        
        echo "Adding hard link for nginx"
        # sudo mv ~/PycharmProjects/$project_dir/configs/nginx.conf /etc/nginx/sites-enabled/$project_shortname.conf
        # if [[ -f ~/PycharmProjects/$project_dir/configs/nginx.conf ]]
        # then
        #     rm ~/PycharmProjects/$project_dir/configs/nginx.conf
        # fi
        if [[ $OSTYPE == 'darwin'* ]];
        then
            echo "Creating symlink for MacOS"
            sudo ln -f ~/PycharmProjects/$project_dir/configs/nginx.conf /usr/local/etc/nginx/sites-enabled/$project_shortname.conf
        else
            sudo ln -f ~/PycharmProjects/$project_dir/configs/nginx.conf /etc/nginx/sites-enabled/$project_shortname.conf
        fi
        # End of create project directory.
        fi

        if [[ -d ~/PycharmProjects/$project_dir/venv ]]
        then
            echo "Removing existing venv to replace it..."
            rm -R ~/PycharmProjects/$project_dir/venv
        fi

        if [[ $project_version == "8.0" ]] || [[ $project_version == "9.0" ]] || [[ $project_version == "10.0" ]];
            then
            
            echo "Creating Python 2.7 venv."
            virtualenv --python=/usr/bin/python2.7 ~/PycharmProjects/$project_dir/venv
            if [[ $? -ne 0 ]]; then
                echo "Failed to create venv..."
                exit 1
            fi
        # elif [[ $project_version == "11.0" ]] || [[ $project_version == "12.0" ]] || [[ $project_version == "13.0" ]] || [[ $project_version == "14.0" ]];
        elif [[ $project_version == "11.0" ]] || [[ $project_version == "12.0" ]] || [[ $project_version == "13.0" ]];
        then
            if [[ $OSTYPE == 'darwin'* ]];
            then
                pyenv global 3.7
                echo "Creating Python 3 venv for macOS."
                python3 -m venv ~/PycharmProjects/$project_dir/venv
                if [[ $? -ne 0 ]]; then
                    echo "Failed to create venv..."
                    exit 1
                fi
            else
                echo "Creating Python 3.7 venv."
                python3.7 -m venv ~/PycharmProjects/$project_dir/venv
                if [[ $? -ne 0 ]]; then
                    echo "Failed to create venv..."
                    exit 1
                fi
            fi
        else
            if [[ $OSTYPE == 'darwin'* ]];
            then
                pyenv global 3.8
                echo "Creating Python 3 venv for macOS."
                python3 -m venv ~/PycharmProjects/$project_dir/venv
                if [[ $? -ne 0 ]]; then
                    echo "Failed to create venv..."
                    exit 1
                fi
            else
                echo "Creating Python 3.8 venv."
                python3.8 -m venv ~/PycharmProjects/$project_dir/venv
                if [[ $? -ne 0 ]]; then
                    echo "Failed to create venv..."
                    exit 1
                fi
            fi
        fi

        echo "Activating venv..."
        source ~/PycharmProjects/$project_dir/venv/bin/activate
        if [[ $? -ne 0 ]]; then
            echo "Failed to activate venv..."
            exit 1
        fi
        # Upgrade pip in venv
        python -m pip install --upgrade pip
        contents=""
        if [[ $install_wsl == "y" ]]
        then
            python_version=$(python --version)
            project_path="\\\\\\\\wsl\$\\\\$WSL_DISTRO_NAME$HOME/PycharmProjects/$project_dir"
            wsl_username=$($(powershell.exe -Command \"echo \$env:UserName\") | xargs)
            wsl_username="${wsl_username%%[[:cntrl:]]}"
            wsl_userpath="/mnt/c/users/$wsl_username/appdata/roaming/jetbrains"
            pycharm_path=$(find $wsl_userpath -maxdepth 1 -type d -regex '.*/PyCharm[0-9].*' | sort -r | head -n 1)
            
            while [[ ! $pycharm_path ]]
            do
                echo "==================================================================================================="
                echo "---------------------------------------------------------------------------------------------------"
                echo "Unable to find PyCharm options."
                echo ""
                echo "If you have installed PyCharm but have not yet launched it for the first time, please open "
                echo "and close PyCharm Pro before continuing. "
                echo ""
                read -p "Press ENTER when ready to continue..."
                echo ""
                echo "Retrying..."
                echo ""
                # Retry getting path.
                wsl_userpath="/mnt/c/users/$wsl_username/appdata/roaming/jetbrains"
                pycharm_path=$(find $wsl_userpath -maxdepth 1 -type d -regex '.*/PyCharm[0-9].*' | sort -r | head -n 1)
                
            done
            
            pycharm_jdk_path=$pycharm_path/options/jdk.table.xml

            python_venv_path="$project_path/venv/bin/python"
            configuration_name="$python_version @ $WSL_DISTRO_NAME for $project_dir"
            if [[ ! $(cat $pycharm_jdk_path | grep -q configuration_name) ]];
            then
                contents="\ \ \ <jdk version=\"2\">\n\ \ \ \ \ <name value=\"$configuration_name\" />\n\ \ \ \ \ <type value=\"Python SDK\" />\n\ \ \ \ \ <version value=\"$python_version\" />\n\ \ \ \ \ <homePath value=\"$python_venv_path\" />\n\ \ \ \ \ <roots>\n\ \ \ \ \ \ <classPath>\n\ \ \ \ \ \ <root type=\"composite\" />\n\ \ \ \ \ \ </classPath>\n\ \ \ \ \ <sourcePath>\n\ \ \ \ \ <root type=\"composite\" />\n\ \ \ \ \ </sourcePath>\n\ \ \ \ \ </roots>\n\ \ \ \ \ <additional INTERPRETER_PATH=\"$HOME/PycharmProjects/$project_dir/venv/bin/python\" HELPERS_PATH=\"\" INITIALIZED=\"false\" VALID=\"true\" RUN_AS_ROOT_VIA_SUDO=\"false\" SKELETONS_PATH=\"\" VERSION=\"\" DISTRIBUTION_ID=\"$WSL_DISTRO_NAME\" />\n\ \ \ \ </jdk>\n"
            fi
        else
            python_version=$(python --version)
            project_path="~/PycharmProjects/$project_dir"
            
            pycharm_path=$(find ~/.config/JetBrains -maxdepth 1 -type d -regex '.*/PyCharm[0-9].*' | sort -r | head -n 1)
            
            while [[ ! $pycharm_path ]]
            do
                echo "==================================================================================================="
                echo "---------------------------------------------------------------------------------------------------"
                echo "Unable to find PyCharm options."
                echo ""
                echo "If you have installed PyCharm but have not yet launched it for the first time, please open "
                echo "and close PyCharm Pro before continuing. "
                echo ""
                read -p "Press ENTER when ready to continue..."
                echo ""
                echo "Retrying..."
                echo ""
                # Retry getting path.
                
                pycharm_path=$(find ~/.config/JetBrains -maxdepth 1 -type d -regex '.*/PyCharm[0-9].*' | sort -r | head -n 1)                
            done
            
            pycharm_jdk_path=$pycharm_path/options/jdk.table.xml

            python_venv_path="\$USER_HOME\$/PycharmProjects/$project_dir/venv/bin/python"
            configuration_name="$python_version for $project_dir"
            if [[ ! $(cat $pycharm_jdk_path | grep -q configuration_name) ]];
            then
                contents="\ \ \ <jdk version=\"2\">\n\ \ \ \ \ <name value=\"$configuration_name\" />\n\ \ \ \ \ <type value=\"Python SDK\" />\n\ \ \ \ \ <version value=\"$python_version\" />\n\ \ \ \ \ <homePath value=\"$python_venv_path\" />\n\ \ \ \ \ <roots>\n\ \ \ \ \ \ <classPath>\n\ \ \ \ \ \ <root type=\"composite\" />\n\ \ \ \ \ \ </classPath>\n\ \ \ \ \ <sourcePath>\n\ \ \ \ \ <root type=\"composite\" />\n\ \ \ \ \ </sourcePath>\n\ \ \ \ \ </roots>\n\ \ \ \ \ <additional ASSOCIATED_PROJECT_PATH=\"\$USER_HOME\$/PycharmProjects/$project_dir\" INTERPRETER_PATH=\"$HOME/PycharmProjects/$project_dir/venv/bin/python\" HELPERS_PATH=\"\" INITIALIZED=\"false\" VALID=\"true\" RUN_AS_ROOT_VIA_SUDO=\"false\" SKELETONS_PATH=\"\" VERSION=\"\" />\n\ \ \ \ </jdk>\n"
            fi
        fi

        # Create file if missing
        if [[ $pycharm_jdk_path ]] && [[ ! -f $pycharm_jdk_path ]];
        then
            # If the file doesn't exist yet, create it.
            cat >> $pycharm_jdk_path <<EOL
<application>
  <component name="ProjectJdkTable">

  </component>
</application>
EOL
            # fix permissions of jdk.table.xml file.
            if [[ $install_wsl ]]
            then
                sudo chmod 777 $pycharm_path/options/jdk.table.xml
            fi
        fi
        
        # Check if the configuration with this name already exists.
        if ! $(cat $pycharm_jdk_path | grep -q "<name value=\"$configuration_name\""); 
        then
            echo "Setting up Python interpreter in PyCharm..."
            
            sudo sed -i -e "/^[[:space:]]*<\/component>[[:space:]]*$/i\ $contents" $pycharm_jdk_path
            if [[ $install_wsl ]]
            then
                sudo chmod 777 $pycharm_path/options/jdk.table.xml
            fi
        fi
    
        echo "Preparing Pycharm Idea and Odoo config files..."
        if [[ $WSL_DISTRO_NAME ]];
        then
            pycharm_project_path="\\\\wsl\$\\$WSL_DISTRO_NAME$HOME/PycharmProjects/"
        else
            pycharm_project_path="$HOME/PycharmProjects/"
        fi

        if [[ $project_version != "9.0" ]] && [[ $project_version != "10.0" ]] && [[ ! -f ~/PycharmProjects/$project_dir/.idea/$project_dir.iml ]];
        then
            echo "Creating .iml file at ~/PycharmProjects/$project_dir/.idea/$project_dir.iml"
            cat >> ~/PycharmProjects/$project_dir/.idea/$project_dir.iml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<module type="PYTHON_MODULE" version="4">
  <component name="NewModuleRootManager">
    <content url="file://\$MODULE_DIR\$">
      <excludeFolder url="file://\$MODULE_DIR\$/venv" />
    </content>
    <content url="file://\$MODULE_DIR\$/../shared/v$project_version/enterprise" />
    <content url="file://\$MODULE_DIR\$/../shared/v$project_version/odoo" />
    <content url="file://\$MODULE_DIR\$/../shared/v$project_version/odoo-stubs" />
    <orderEntry type="jdk" jdkName="$configuration_name" jdkType="Python SDK" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
  <component name="PyDocumentationSettings">
    <option name="format" value="PLAIN" />
    <option name="myDocStringFormat" value="Plain" />
  </component>
</module>
EOL
        elif [[ ! -f ~/PycharmProjects/$project_dir/.idea/$project_dir.iml ]];
        then
            echo "Creating .iml file at ~/PycharmProjects/$project_dir/.idea/$project_dir.iml"
            cat >> ~/PycharmProjects/$project_dir/.idea/$project_dir.iml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<module type="PYTHON_MODULE" version="4">
  <component name="NewModuleRootManager">
    <content url="file://\$MODULE_DIR\$">
      <excludeFolder url="file://\$MODULE_DIR\$/venv" />
    </content>
    <content url="file://\$MODULE_DIR\$/../shared/v$project_version/enterprise" />
    <content url="file://\$MODULE_DIR\$/../shared/v$project_version/odoo" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
  <component name="PyDocumentationSettings">
    <option name="format" value="PLAIN" />
    <option name="myDocStringFormat" value="Plain" />
  </component>
</module>
EOL
        fi

        if [[ ! -f ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_single.xml ]];
        then
            echo "Creating debug configurations for Pycharm in ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_single.xml"
            mkdir ~/PycharmProjects/$project_dir/.idea/runConfigurations
            cat >> ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_single.xml <<EOL
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Odoo $version - Single Worker" type="PythonConfigurationType" factoryName="Python" nameIsGenerated="false">
    <module name="$project_dir" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="PARENT_ENVS" value="true" />
    <envs>
      <env name="PYTHONUNBUFFERED" value="1" />
    </envs>
    <option name="SDK_HOME" value="$pycharm_project_path$project_dir/venv/bin/python" />
    <option name="WORKING_DIRECTORY" value="\$PROJECT_DIR\$" />
    <option name="IS_MODULE_SDK" value="true" />
    <option name="ADD_CONTENT_ROOTS" value="true" />
    <option name="ADD_SOURCE_ROOTS" value="true" />
    <EXTENSION ID="PythonCoverageRunConfigurationExtension" runner="coverage.py" />
    <option name="SCRIPT_NAME" value="\$PROJECT_DIR\$/../shared/v$project_version/odoo/odoo-bin" />
    <option name="PARAMETERS" value="--config=./configs/odoo-server.conf" />
    <option name="SHOW_COMMAND_LINE" value="false" />
    <option name="EMULATE_TERMINAL" value="false" />
    <option name="MODULE_MODE" value="false" />
    <option name="REDIRECT_INPUT" value="false" />
    <option name="INPUT_FILE" value="" />
    <method v="2" />
  </configuration>
</component>
EOL
        fi
        if [[ ! -f ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin.xml ]]
        then
            echo "Creating debug configurations for Pycharm in ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin.xml"
            cat >> ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin.xml <<EOL
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Odoo $version" type="PythonConfigurationType" factoryName="Python" nameIsGenerated="false">
    <module name="$project_dir" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="PARENT_ENVS" value="true" />
    <envs>
      <env name="PYTHONUNBUFFERED" value="1" />
    </envs>
    <option name="SDK_HOME" value="$pycharm_project_path$project_dir/venv/bin/python" />
    <option name="WORKING_DIRECTORY" value="\$PROJECT_DIR\$" />
    <option name="IS_MODULE_SDK" value="true" />
    <option name="ADD_CONTENT_ROOTS" value="true" />
    <option name="ADD_SOURCE_ROOTS" value="true" />
    <EXTENSION ID="PythonCoverageRunConfigurationExtension" runner="coverage.py" />
    <option name="SCRIPT_NAME" value="\$PROJECT_DIR\$/../shared/v$project_version/odoo/odoo-bin" />
    <option name="PARAMETERS" value="--config=./configs/odoo-server-workers.conf" />
    <option name="SHOW_COMMAND_LINE" value="false" />
    <option name="EMULATE_TERMINAL" value="false" />
    <option name="MODULE_MODE" value="false" />
    <option name="REDIRECT_INPUT" value="false" />
    <option name="INPUT_FILE" value="" />
    <method v="2" />
  </configuration>
</component>
EOL
        fi
        if [[ ! -f ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_test.xml ]]
        then
            echo "Creating debug configurations for Pycharm in ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_test.xml"
            cat >> ~/PycharmProjects/$project_dir/.idea/runConfigurations/odoo_bin_test.xml <<EOL
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Odoo $version - Init Test" type="PythonConfigurationType" factoryName="Python" nameIsGenerated="false">
    <module name="$project_dir" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="PARENT_ENVS" value="true" />
    <envs>
      <env name="PYTHONUNBUFFERED" value="1" />
    </envs>
    <option name="SDK_HOME" value="$pycharm_project_path$project_dir/venv/bin/python" />
    <option name="WORKING_DIRECTORY" value="\$PROJECT_DIR\$" />
    <option name="IS_MODULE_SDK" value="true" />
    <option name="ADD_CONTENT_ROOTS" value="true" />
    <option name="ADD_SOURCE_ROOTS" value="true" />
    <EXTENSION ID="PythonCoverageRunConfigurationExtension" runner="coverage.py" />
    <option name="SCRIPT_NAME" value="\$PROJECT_DIR\$/../shared/v$project_version/odoo/odoo-bin" />
    <option name="PARAMETERS" value="--config=./configs/test-server.conf -i account --test-tags account -d test_db --no-http --stop-after-init" />
    <option name="SHOW_COMMAND_LINE" value="false" />
    <option name="EMULATE_TERMINAL" value="false" />
    <option name="MODULE_MODE" value="false" />
    <option name="REDIRECT_INPUT" value="false" />
    <option name="INPUT_FILE" value="" />
    <method v="2" />
  </configuration>
</component>
EOL
        fi
        if [[ ! -f ~/PycharmProjects/$project_dir/.idea/modules.xml ]]
        then
            echo "Creating .xml file at ~/PycharmProjects/$project_dir/.idea/modules.xml"
            cat >> ~/PycharmProjects/$project_dir/.idea/modules.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://\$PROJECT_DIR\$/.idea/$project_dir.iml" filepath="\$PROJECT_DIR\$/.idea/$project_dir.iml" />
    </modules>
  </component>
</project>
EOL
        fi
        echo "Installing requirements into venv..."
        
        if [[ $project_version == "8.0" ]] || [[ $project_version == "9.0" ]] || [[ $project_version == "10.0" ]];
        then
            # Older versions use Python 2.7 and won't work with latest pydevd.
            pip install wheel pydevd-odoo==1.1

            # less is required for old versions of Odoo.
            sudo npm install -g less less-plugin-clean-css
        else
            # Install wheel and pydevd-odoo into venv.
            pip install wheel pydevd-odoo
        fi
        if [[ -f ~/PycharmProjects/$project_dir/requirements.txt ]];
        then
            # If there is a requirements file in the project directory, use that instead of Odoo's
            # The reason being you may override the requirements to resolve compatibility with 
            # Pycharm debugger.
            echo "Overriding requirements from Odoo and using project directory..."
            sleep 10s
            pip install -r ~/PycharmProjects/$project_dir/requirements.txt
        else
            echo "Installing requirements from Odoo."
            sleep 10s

            version_url="https://raw.githubusercontent.com/odoo/odoo/"
            version_url+=$project_version
            version_url+="/requirements.txt"

            echo "Downloading from $version_url..."
            # Download requirements.txt and overwrite existing file.
            wget -O requirements.txt $version_url
            
            if [[ $? -ne 0 ]]; then
                echo "Requirements file failed to download..."
                exit 1
            else
                echo "Downloaded requirements.txt file"
            fi
            pip install -r requirements.txt
        fi
        
        if [[ $? -ne 0 ]]; 
        then
            echo "Requirements failed to install correctly..."
            exit 1
        else
            
            
            if [[ $install_wsl == "y" ]];
            then
                if ! $(cat /mnt/c/Windows/System32/drivers/etc/hosts | grep -q $project_shortname.odoo.test); 
                then
                    echo "Adding nginx hostname to the Windows hosts file."
                    echo "An elevated command will run to add the file."
                    echo " "
                    echo "Hostname $project_shortname.odoo.test"
                    echo ""
                    echo "==================================================================================================="
                    sleep 10s
                    powershell.exe -Command "Start-Process PowerShell -Verb RunAs \"-NoProfile -ExecutionPolicy Bypass -Command \`\"Add-Content -Path \$env:windir\System32\drivers\etc\hosts \`\"127.0.0.1\`\`t$project_shortname.odoo.test\`\"\`\"\";"
                    if [[ $? -ne 0 ]];  then
                        echo "Failed to add hostname to your hosts file on Windows..."
                        echo "Please add this record to the bottom of your Windows hosts file::"
                        echo "127.0.0.1    $project_shortname.odoo.test"
                        read -p "Press ENTER to continue..."
                        echo "After you have added the record to your Windows hosts file, you'll be able to"
                        echo "access Odoo via http://$project_shortname.odoo.test"
                        # echo "Ensure nginx is running by using this command:"
                        # echo " "
                        # echo "sudo service nginx restart"
                        # read -p "Press ENTER to continue..."
                    else
                        echo "Hostname added to Windows hosts file..."
                        echo "You can access your local Odoo dev environment via "
                        echo "http://$project_shortname.odoo.test"
                        echo ""
                        # echo "Ensure nginx is running by using this command:"
                        # echo " "
                        # echo "sudo service nginx restart"
                        read -p "Press ENTER to continue..."
                    fi
                else
                    echo "You can access your local Odoo dev environment via "
                    echo "http://$project_shortname.odoo.test"
                    echo ""
                    # echo "Ensure nginx is running by using this command:"
                    # echo " "
                    # echo "sudo service nginx restart"
                    read -p "Press ENTER to continue..."
                fi

                if [[ $postgres_option == "4" ]];
                then
                    # TODO: Setup postgres firewall rule with IP range to allow psql to connect to Windows.
                    echo "Checking firewall rules on Windows..."
                    wsl_inbound_firewall_rule=$(powershell.exe Get-NetFirewallRule -DisplayName \'WSL Inbound\' -ErrorAction SilentlyContinue)
                    wsl_postgres_firewall_rule=$(powershell.exe Get-NetFirewallRule -DisplayName \'PostgreSQL on $postgres_port\' -ErrorAction SilentlyContinue)

                    if [[ ! $wsl_inbound_firewall_rule ]] && [[ ! $wsl_postgres_firewall_rule ]];
                    then
                        echo "Setting up firewall rules for accessing Postgres on Windows..."
                        echo "An elevated command will run to setup the firewall rules."
                        echo ""
                        echo "==================================================================================================="
                        sleep 10s
                        powershell.exe -Command "Start-Process PowerShell -Verb RunAs \"-NoProfile -NoExit -ExecutionPolicy Bypass -Command \`\"New-NetFirewallRule -DisplayName 'WSL Inbound' -Direction Inbound -InterfaceAlias 'vEthernet (WSL)' -Action Allow ; Get-NetFirewallRule | where DisplayName -ILike 'PyCharm*' | Remove-NetFirewallRule ; New-NetFirewallRule -DisplayName 'PostgreSQL on $postgres_port' -Profile 'Private' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $postgres_port\`\" \";"
                        echo "Done!"
                        echo "Check the output in the Powershell window to ensure the command worked correctly." 
                    fi
                fi

            else
                if [[ ! $(cat /etc/hosts | grep -q $project_shortname.odoo.test) ]];
                then
                    echo "Adding nginx hostname to your hosts file."
                    echo "127.0.0.1     $project_shortname.odoo.test" | sudo tee -a /etc/hosts
                    echo "You can access your local Odoo dev environment via "
                    echo "http://$project_shortname.odoo.test"
                    echo ""
                    read -p "Press ENTER to continue..."
                    # echo "Ensure nginx is running by using this command:"
                    # echo " "
                    # echo "sudo service nginx restart"
                else
                    echo "You can access your local Odoo dev environment via "
                    echo "http://$project_shortname.odoo.test"
                    echo ""
                    # echo "Ensure nginx is running by using this command:"
                    # echo " "
                    # echo "sudo service nginx restart"
                    read -p "Press ENTER to continue..."
                fi
            fi

            if [[ -f ~/PycharmProjects/$project_dir/$project_addons/setup.sh ]];
            then
                export project_dir
                export project_shortname
                export project_addons
                export project_version
                export version
                export postgres_hostname
                export postgres_port
                export postgres_username
                export postgres_password
                

                echo ""
                echo ""
                echo ""
                read -p "Found setup.sh in project's addons. Press ENTER to continue setting up project specific dependencies..."
                chmod +x setup.sh
                ~/PycharmProjects/$project_dir/$project_addons/setup.sh
            fi

            # Install requirements after running setup.sh. This is in case the project's setup.sh installs dependancies.
            if [[ -f ~/PycharmProjects/$project_dir/$project_addons/requirements.txt ]];
            then
                echo "Installing requirements found in project addons directory..."
                sleep 10s
                pip install -r ~/PycharmProjects/$project_dir/$project_addons/requirements.txt
            fi
            
            if [[ $? -ne 0 ]]; 
            then
                echo "Requirements failed to install correctly..."
                exit 1
            fi

            # Ensure owner of the project directory is the current user.
            sudo chown -R $(id -u):$(id -g) ~/PycharmProjects/$project_dir
            
            echo "---------------------------------------------------------------------------------------------------"
            echo "==================================================================================================="
            echo "---------------------------------------------------------------------------------------------------"
            echo " Your project is setup with the following directory structure. "
            echo " "
            echo " ~/PycharmProjects "
            echo " |- $project_dir                  # Main Project Directory" 
            echo "   |- $project_addons             # Addons Directory"
            echo "   |- configs                     # conf files"
            echo "     |- nginx.conf                # Nginx site config"
            echo "     |- odoo-server.conf "
            echo "     |- odoo-server-workers.conf "
            echo "     |- test-server.conf "
            echo "   |- venv                        # venv "
            echo " |- shared                        # Shared repositores "
            echo "   |- v$project_version "
            echo "     |- odoo              "
            echo "     |- enterprise        "
            echo "     |- odoo-stubs        "
            echo "---------------------------------------------------------------------------------------------------"
            echo "==================================================================================================="
            
            read -p "Setup another project? [y/n] " setup_another_project
            if [[ $setup_another_project != "y" ]];
            then
                work=0
            fi
        fi
    done
fi

echo "Setup complete, exiting..."
# Windows related info.
if [[ $install_wsl == "y" ]];
then
    if [[ $project_shortname ]]
    then
        echo "---------------------------------------------------------------------------------------------------"
        echo "You can access your local Odoo dev environment via "
        echo "http://$project_shortname.odoo.test"
        echo ""
    fi
    echo "---------------------------------------------------------------------------------------------------"
    echo "==================================================================================================="
    echo "==================================================================================================="
    echo "==================================================================================================="
    echo "---------------------------------------------------------------------------------------------------"
    echo " "
    echo " If you are using Postgresql on Windows, add this to your pg_hba.conf: "
    echo " host    all             all             127.0.0.1/32            md5"
    echo " host    all             all             172.0.0.0/8             md5"
    echo "==================================================================================================="
    echo " " 
    echo " Services on your Windows machine, such as PostgreSQL, can be accessed by applications on WSL " 
    echo " using your computer's hostname: $win_hostname "
    echo " "
    echo " Make sure to configure appropriate firewall and application rules. "
    echo ""
    echo "==================================================================================================="
fi