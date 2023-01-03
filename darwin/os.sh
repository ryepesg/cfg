mv -n ~/data-vault "${HOME}/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/plain-text"
# The symlink is only for quick access, but Logseq should probably point to the real dir
ln -s "${HOME}/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/plain-text" ~/data-vault
#xcode-select --install
echo MacOS setup completed!