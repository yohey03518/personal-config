CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
REPO_MAC="$HOME/git/personal-config/cursor/mac"

mv "$CURSOR_USER/keybindings.json" "$REPO_MAC/keybindings.json"
mv "$CURSOR_USER/settings.json" "$REPO_MAC/settings.json"

ln -s "$REPO_MAC/keybindings.json" "$CURSOR_USER/keybindings.json"
ln -s "$REPO_MAC/settings.json" "$CURSOR_USER/settings.json"
