# This script pulls the latest changes from the remote repository and updates submodules.

echo "Pulling main repository..."
git pull

echo "Updating submodules..."
git submodule update --remote --merge

echo "Checking submodule status..."
git submodule foreach git status