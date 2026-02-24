options=("Install as Debian Package" "Install as UV Tool")

echo "Please choose an action:"

select opt in "${options[@]}"
do
    case $opt in
        "Install as Debian Package")
            echo "Installing as Debian Package..."
            sudo apt install ranger
            break
            ;;
        "Install as UV Tool")
            echo "Installing as UV Tool..."
            uv tool install ranger
            break
            ;;
        *) 
            echo "Invalid option $REPLY. Try again."
            ;;
    esac
done