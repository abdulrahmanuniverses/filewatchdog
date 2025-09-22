#!/usr/bin/env bash
#this code is written by Abdulrahman Ahmed
#as a port of  my learning journey
#It’s under a **public license** → free for anyone to use and improve. 
# Default paths
LOGSRC="/var/log/"
DNSRESOLV="/etc/resolv.conf"
BACKIPCPY="/var/backups"

# Banners
MAINBANNER=$(figlet -f slant "FileWatchDog")
FCBANNER=$(figlet -f slant "Logs Manager")
FABANNER=$(figlet -f slant "EYE ON NETWORK")

# ---------------------------
# Network Check Functions
# ---------------------------
NETCHECK() {
    echo -e "$FABANNER\n"
    echo -e "1. Check open files in a directory"
    echo -e "2. Details about an IP address"
    echo -e "3. Devices connected to your network"
    read -p "Choose a number (1-3): " NETCHOICE

    case $NETCHOICE in
        1)
            read -p "Enter directory path: " OPNFILES_CHECK
            [[ -z "$OPNFILES_CHECK" ]] && echo "You must enter a path!" && return
            echo "Running lsof command..."
            lsof +D "$OPNFILES_CHECK"
            ;;
        2)
            read -p "Write the IP address: " IPADDR
            [[ -z "$IPADDR" ]] && echo "You must enter an IP!" && return
            echo "Running whois command..."
            whois "$IPADDR"
            ;;
        3)
            read -p "Enter your local IP (e.g. 192.168.1.1): " localip
            [[ -z "$localip" ]] && echo "You must enter your local IP!" && return
            echo "Scanning network with nmap..."
            nmap -sn "$localip"/24
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# ---------------------------
# Logs Manager Functions
# ---------------------------
LOGSFUNC() {
    echo -e "$FCBANNER\n"
    echo -e "1. Backup & compress log files"
    echo -e "2. Delete log files"
    echo -e "3. Send backups to remote server"
    read -p "Choose a number (1-3): " LOGOP

    case $LOGOP in
        1)
            read -p "Enter the log directory path (default /var/log/): " USERLOGSRC
            LOGSRC=${USERLOGSRC:-/var/log/}
            [[ ! -d "$LOGSRC" ]] && echo "Directory $LOGSRC does not exist!" && return

            mkdir -p "$BACKIPCPY"
            ARCHIVE="$BACKIPCPY/logs-$(date +%F_%H-%M-%S).tar.gz"

            echo "Compressing log files from $LOGSRC ..."
            tar -czf "$ARCHIVE" "$LOGSRC"/*.log 2>/dev/null
            echo "Logs compressed and saved to: $ARCHIVE"
            ;;
        2)
            read -p "This will ERASE all .log files! Continue? (Y/N): " DELETSURE
            if [[ "$DELETSURE" =~ ^[Yy]$ ]]; then
                read -p "Enter the log directory (absolute path): " DELETALL
                [[ -z "$DELETALL" ]] && echo "You must enter a directory!" && return
                sudo rm -i "$DELETALL"/*.log
                echo "All log files deleted from $DELETALL"
            else
                echo "Operation cancelled."
            fi
            ;;
        3)
            read -p "Enter the remote machine username and IP (e.g. user@192.168.1.10): " USERREMOTEHOST
            [[ -z "$USERREMOTEHOST" ]] && echo "You must enter a remote host!" && return

            read -p "Enter the local backup archive path: " LOCALBACKUP
            [[ -z "$LOCALBACKUP" ]] && echo "You must enter a local backup path!" && return
            [[ ! -f "$LOCALBACKUP" && ! -d "$LOCALBACKUP" ]] && echo "Path $LOCALBACKUP not found!" && return

            read -p "Enter the remote backup path (absolute path on remote machine): " REMOTEPATH
            [[ -z "$REMOTEPATH" ]] && echo "You must enter a remote path!" && return

            echo "Sending $LOCALBACKUP to $USERREMOTEHOST:$REMOTEPATH ..."
            rsync -avz "$LOCALBACKUP" "$USERREMOTEHOST:$REMOTEPATH"
            echo "Transfer complete."
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# ---------------------------
# Main Menu
# ---------------------------
while true; do
    clear
    echo "$MAINBANNER"
    echo -e "\nScript by Abdulrahman Ahmed"
    echo -e "This is part of my learning journey\n"
    echo "############ MAIN MENU ############"
    echo "1. Manage logs and files"
    echo "2. Manage your Network"
    echo "3. Exit"
    read -p "Choose a number (1-3): " USEROPTION

    case $USEROPTION in
        1) LOGSFUNC ;;
        2) NETCHECK ;;
        3) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid selection" ;;
    esac

    echo ""
    read -p "Run another command? (y/n): " LOOP
    [[ ! "$LOOP" =~ ^[Yy]$ ]] && echo "Goodbye!" && exit 0
done

                                   
