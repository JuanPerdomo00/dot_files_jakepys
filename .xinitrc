export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
setxkbmap es
autorandr --change

pipewire &
wireplumber &
pipewire-pulse &

exec i3
