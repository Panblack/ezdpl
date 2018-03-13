# Used by bin/buildhtml
funMakeProduction() {
    echo "Making production: $1"
    case $1 in
    sales)
        sed -i /'var *webname'/d ./js/allActive.js
        sed -i '1i\var webname = "https://www.example.com/salesapi"'   ./js/allActive.js

        sed -i /'var *urlBackend'/d ./js/mybase.js
        sed -i '1i\var urlBackend = "http://www.example.com/salesapi"' ./js/mybase.js
        ;;
	
    portal)
        sed -i /'var *webname'/d ./js/allActive.js
	sed -i '1i\var webname = "https://portal.example.com/backendapi"' ./js/allActive.js
	;;
    esac
    echo "Made production: $1"
}

