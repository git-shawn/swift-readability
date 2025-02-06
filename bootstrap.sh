if ! command -v nest >/dev/null 2>&1; then
  curl -s https://raw.githubusercontent.com/mtj0928/nest/main/Scripts/install.sh | bash
fi

~/.nest/bin/nest bootstrap nestfile.yaml

npm install
npm run build
