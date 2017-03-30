mkdir -p $HOME/.bash_profile.d
if [ ! -e $HOME/.bash_profile.d/peeps.bash ]; then
  ln -s $HOME/Documents/Dev/Projects/peeps/peeps.bash $HOME/.bash_profile.d/peeps.bash
fi
if [ ! -e peeps.db ]; then
  sqlite3 peeps.db < schema.sqlite 
fi
echo "to enable, add the following line to your ~/.bash_profile:
  source ~/.bash_profile.d/peeps.bash"
