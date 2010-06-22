# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

echo
echo 'Welcome back!'
echo
fortune -s
echo
uptime
